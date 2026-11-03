library(tidyverse)
library(readxl)
library(here)

# 1. Load LSOA population
read_pop <- function(file, year) {
  read_excel(
    here("data", "raw", file),
    sheet = paste0("Mid-", year, " LSOA 2021"),
    skip = 3
  ) %>%
    dplyr::select(
      LSOA21CD   = `LSOA 2021 Code`,
      Population = Total
    ) %>%
    mutate(Year = year)
}

#Combine 2016-2021 and 2022-2024 population
pop_lsoa <- bind_rows(
  map(2016:2021, ~ read_pop("sapelsoabroadage20112022.xlsx", .x)),
  map(2022:2024, ~ read_pop("sapelsoabroadage20222024.xlsx", .x))  # 2022 from the newer, revised file
) %>%
  filter(str_starts(LSOA21CD, "E"))  # England only

# 2. Attach IMD2025 decile and convert to quintile

imd25 <- read_excel(
  here("data", "raw", "File_1_IoD2025_Index_of_Multiple_Deprivation.xlsx"),
  sheet = "IMD25"
) %>%
  dplyr::select(
    LSOA21CD   = `LSOA code (2021)`,
    IMD_Decile = `Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOA`
  )

pop_imd <- pop_lsoa %>%
  left_join(imd25, by = "LSOA21CD") %>%
  mutate(IMD_num = ceiling(IMD_Decile / 2))  


# 3. Aggregate to Year x IMD quintile

population_all <- pop_imd %>%
  group_by(Year, IMD_num) %>%
  summarise(Population = sum(Population), .groups = "drop")

write_csv(
  population_all,
  here("data", "processed", "population_by_imd.csv")
)
