library(tidyverse)
library(broom)
library(readxl)

#1. Patients by age band (NHSBSA)
raw <- read_excel(
  here("data", "raw", "mumh_bnf0404_2025.xlsx"),
  sheet = "Age_Band",       
  col_names = FALSE
)
header_row <- which(raw[[1]] == "Calendar Year")
header_row                    
age_sheet <- "Age_Band" 
age_file  <- here("data", "raw", "mumh_bnf0404_2025.xlsx")

raw <- read_excel(age_file, sheet = age_sheet, col_names = FALSE)
header_row <- which(str_trim(raw[[1]]) == "Calendar Year")[1]


# 2. Population by age group and IMD quintile (ONS + IMD2025)

read_pop_age <- function(file, year) {
  read_excel(
    here("data", "raw", file),
    sheet = paste0("Mid-", year, " LSOA 2021"),
    skip  = 3
  ) %>%
    transmute(
      LSOA21CD = `LSOA 2021 Code`,
      Year     = year,
      `0-15`   = `F0 to 15`    + `M0 to 15`,
      `16-29`  = `F16 to 29`   + `M16 to 29`,
      `30-44`  = `F30 to 44`   + `M30 to 44`,
      `45-64`  = `F45 to 64`   + `M45 to 64`,
      `65+`    = `F65 and over` + `M65 and over`
    )
}

pop_age_lsoa <- bind_rows(
  map(2016:2021, ~ read_pop_age("sapelsoabroadage20112022.xlsx", .x)),
  map(2022:2024, ~ read_pop_age("sapelsoabroadage20222024.xlsx", .x))
) %>%
  filter(str_starts(LSOA21CD, "E")) %>%
  pivot_longer(`0-15`:`65+`, names_to = "age_group", values_to = "Population")

imd25 <- read_excel(
  here("data", "raw", "File_1_IoD2025_Index_of_Multiple_Deprivation.xlsx"),
  sheet = "IMD25"
) %>%
  dplyr::select(
    LSOA21CD   = `LSOA code (2021)`,
    IMD_Decile = `Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOA`
  )

pop_age_imd <- pop_age_lsoa %>%
  left_join(imd25, by = "LSOA21CD") %>%
  mutate(IMD_num = ceiling(IMD_Decile / 2)) %>%
  group_by(Year, IMD_num, age_group) %>%
  summarise(Population = sum(Population), .groups = "drop")


# 3. Age structure by quintile

age_structure <- pop_age_imd %>%
  filter(Year %in% c(2016, 2024)) %>%
  group_by(Year, IMD_num) %>%
  mutate(share = Population / sum(Population)) %>%
  ungroup() %>%
  dplyr::select(Year, IMD_num, age_group, share) %>%
  pivot_wider(names_from = age_group, values_from = share) %>%
  mutate(across(-c(Year, IMD_num), ~ round(.x * 100, 1)))

age_structure 
write_csv(age_structure, here("data", "processed", "age_structure_by_quintile.csv"))


# 4. National age-specific rates and expected counts 

national_rates <- pop_age_imd %>%
  group_by(Year, age_group) %>%
  summarise(Population = sum(Population), .groups = "drop") %>%
  left_join(age_cases, by = c("Year", "age_group")) %>%
  mutate(rate = Patients / Population)

national_rates

expected <- pop_age_imd %>%
  left_join(dplyr::select(national_rates, Year, age_group, rate),
            by = c("Year", "age_group")) %>%
  group_by(Year, IMD_num) %>%
  summarise(Expected = sum(Population * rate), .groups = "drop")


# 5. Join to observed counts 

model_age <- read_csv(
  here("data", "processed", "final_rates.csv"),
  show_col_types = FALSE
) %>%
  filter(Year >= 2016, Year <= 2024) %>%
  left_join(expected, by = c("Year", "IMD_num")) %>%
  mutate(
    SIR        = Total_patients / Expected,   
    IMD_factor = relevel(factor(IMD_num, levels = 1:5), ref = "5"),
    year_c     = Year - 2016
  )


model_age %>%
  dplyr::select(Year, IMD_num, SIR) %>%
  pivot_wider(names_from = IMD_num, values_from = SIR, names_prefix = "Q") %>%
  mutate(SIR_ratio_Q1_Q5 = Q1 / Q5)


# 6. Age-adjusted negative binomial models
nb_age_int <- MASS::glm.nb(
  Total_patients ~ IMD_factor * year_c + offset(log(Expected)),
  data = model_age
)

nb_age_int_quad <- MASS::glm.nb(
  Total_patients ~ IMD_factor * year_c + I(year_c^2) + offset(log(Expected)),
  data = model_age
)

AIC(nb_age_int, nb_age_int_quad)

age_results <- tidy(nb_age_int_quad, exponentiate = TRUE, conf.int = TRUE) %>%
  mutate(across(c(estimate, conf.low, conf.high), ~ round(.x, 3)),
         p.value = signif(p.value, 3))

age_results
write_csv(age_results, here("data", "processed", "nb_age_adjusted_results.csv"))


# 7. Crude vs age-adjusted (Table 4)

crude_results <- read_csv(
  here("data", "processed", "nb_final_results.csv"),
  show_col_types = FALSE
)

comparison_age <- crude_results %>%
  filter(str_detect(term, "IMD_factor")) %>%
  dplyr::select(term, crude_IRR = estimate, crude_low = conf.low, crude_high = conf.high) %>%
  left_join(
    age_results %>%
      filter(str_detect(term, "IMD_factor")) %>%
      dplyr::select(term, age_IRR = estimate, age_low = conf.low, age_high = conf.high),
    by = "term"
  )

comparison_age
write_csv(comparison_age, here("data", "processed", "crude_vs_age_adjusted.csv"))
