library(tidyverse)
library(broom)
library(here)


# 1. Data
model_data <- read_csv(
  here("data", "processed", "final_rates.csv"),
  show_col_types = FALSE
) %>%
  filter(Year >= 2016, Year <= 2024) %>%
  mutate(
    IMD_factor = relevel(factor(IMD_num, levels = 1:5), ref = "5"),
    year_c     = Year - 2016                                         
  )


#2. Descriptive inequality measures (Table 1)
inequality <- model_data %>%
  dplyr::select(Year, IMD_num, treated_per_1000) %>%
  pivot_wider(
    names_from   = IMD_num,
    values_from  = treated_per_1000,
    names_prefix = "Q"
  ) %>%
  mutate(
    rate_difference = Q1 - Q5,
    rate_ratio      = Q1 / Q5
  )

inequality

write_csv(inequality, here("data","processed", "inequality_by_year.csv"))


# 4. Poisson models and overdispersion

pois_int <- glm(
  Total_patients ~ IMD_factor * year_c + offset(log(Population)),
  family = poisson(link = "log"),
  data   = model_data
)


# 5. Negative binomial models 

#Main effects only
nb_main <- MASS::glm.nb(
  Total_patients ~ IMD_factor + year_c + offset(log(Population)),
  data = model_data
)

#IMD * year interaction
nb_int <- MASS::glm.nb(
  Total_patients ~ IMD_factor * year_c + offset(log(Population)),
  data = model_data
)

#Interaction + common quadratic year term (final model)
nb_int_quad <- MASS::glm.nb(
  Total_patients ~ IMD_factor * year_c + I(year_c^2) + offset(log(Population)),
  data = model_data
)

#Interaction + quadratic year term varying by quintile
nb_int_quad_full <- MASS::glm.nb(
  Total_patients ~ IMD_factor * (year_c + I(year_c^2)) + offset(log(Population)),
  data = model_data
)


# 5. Model comparison 

AIC(pois_int, nb_main, nb_int, nb_int_quad,nb_int_quad_full)

# Likelihood ratio test
lr_test <- function(small, big) {
  stat <- as.numeric(2 * (logLik(big) - logLik(small)))
  df   <- attr(logLik(big), "df") - attr(logLik(small), "df")
  tibble(LR_statistic = stat, df = df,
         p_value = pchisq(stat, df, lower.tail = FALSE))
}

lr_test(nb_main, nb_int)        
lr_test(nb_int, nb_int_quad)  
lr_test(nb_int_quad, nb_int_quad_full)

# 6. Results
final_model <- nb_int_quad
results <- tidy(final_model, exponentiate = TRUE, conf.int = TRUE) %>%
  mutate(across(c(estimate, conf.low, conf.high), ~ round(.x, 3)),
         p.value = signif(p.value, 3))

results

write_csv(results, here("data","processed", "nb_final_results.csv"))


#7. Model estimated rates and average annual change (Table 2)
annual_trend <- model_data %>%
  mutate(fitted_rate = fitted(final_model) / Population * 1000) %>%
  filter(Year %in% c(2016, 2024)) %>%
  dplyr::select(IMD_num, Year, fitted_rate) %>%
  pivot_wider(names_from = Year, values_from = fitted_rate,
              names_prefix = "rate_") %>%
  mutate(
    IMD_quintile            = paste0("Q", IMD_num),
    avg_pct_change_per_year = round(((rate_2024 / rate_2016)^(1 / 8) - 1) * 100, 1)
  ) %>%
  dplyr::select(IMD_quintile, rate_2016, rate_2024, avg_pct_change_per_year) %>%
  arrange(IMD_quintile)

annual_trend
write_csv(annual_trend, here("data", "processed", "annual_trend_by_quintile.csv"))


# 8. Sensitivity analysis : year as a categorical variable
nb_yearfac <- MASS::glm.nb(
  Total_patients ~ factor(Year) + IMD_factor * year_c + offset(log(Population)),
  data = model_data
)

sensitivity <- tidy(nb_yearfac, exponentiate = TRUE, conf.int = TRUE) %>%
  filter(str_detect(term, ":year_c")) %>%
  mutate(across(c(estimate, conf.low, conf.high), ~ round(.x, 3)))

sensitivity
write_csv(sensitivity, here("data", "processed", "sensitivity_yearfactor.csv"))

