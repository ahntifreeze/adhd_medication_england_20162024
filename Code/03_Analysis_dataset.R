library(tidyverse)
library(here)

adhd <- read_csv(
  here("data", "processed", "adhd_clean.csv"),
  show_col_types = FALSE
)

population_all <- read_csv(
  here("data", "processed", "population_by_imd.csv"),
  show_col_types = FALSE
)

#1. Create final data set incorporating IMD and ADHD prescription
final_rates <- adhd %>%
  left_join(
    population_all,
    by = c("Year", "IMD_num")
  ) %>%
  mutate(
    IMD_group = factor(
      IMD_num,
      levels = 1:5,
      labels = c(
        "Q1 (Most deprived)",
        "Q2",
        "Q3",
        "Q4",
        "Q5 (Least deprived)"
      )
    ),
    treated_per_1000 =
      Total_patients / Population * 1000,
    prescribed_per_1000 =
      Total_prescriptions / Population * 1000,
    prescriptions_per_patient =
      Total_prescriptions / Total_patients
  )

final_rates %>%
  filter(is.na(Population))

write_csv(
  final_rates,
  here("data", "processed", "final_rates.csv")
)
