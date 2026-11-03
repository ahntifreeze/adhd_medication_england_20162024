library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(here)


#Open NHSBSA dataset
adhd_IMD_raw <- read_excel(
  here("data", "raw","mumh_bnf0404_2025.xlsx"), 
  sheet = "IMD", 
  skip = 6
)

#rename variable 
adhd_IMD <- adhd_IMD_raw %>%
  dplyr::select(
    Year = 'Calendar Year',
    IMD = 'IMD Quintile',
    Total_patients = 'Total Identified Patients',
    Total_prescriptions = 'Total Items'
  )


adhd_IMD <- adhd_IMD %>%
  filter(IMD != "Unknown")%>%
  mutate(IMD_num = as.numeric(str_extract(IMD, "^\\d"))) %>%
  filter(IMD_num %in% 1:5)


write_csv(adhd_IMD, here("data", "processed", "adhd_clean.csv"))

