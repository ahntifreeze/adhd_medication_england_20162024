library(tidyverse)
library(here)


# 1.Patients receiving ADHD medication per 1,000 population
fig1 <- ggplot(
  final_rates,
  aes(
    x = Year,
    y = treated_per_1000,
    color = IMD_group,
    group = IMD_group
  )
) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Annual ADHD medication utilisation by socioeconomic deprivation",
    subtitle = "England, 2016–2024",
    x = "Year",
    y = "Patients per 1,000 population",
    color = "IMD quintile"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom"
  )

fig1
ggsave(here("outputs", "fig1_treated_rates.png"), fig1, width = 8, height = 5, dpi = 300)

#Fig 2. prescriptions per patient 
fig2<-ggplot(
  final_rates,
  aes(
    x = Year,
    y = prescriptions_per_patient,
    group = IMD_group,
    color = IMD_group
  )
) +
  geom_line() +
  geom_point() +
  labs(
    title = "Average ADHD prescriptions per treated patient",
    subtitle = "(2016-2024)",
    x = "Year",
    y = "Prescriptions per treated patient",
    color = "IMD Quintile"
  ) +
  theme_minimal()
ggsave(here("Outputs", "fig2_items_per_patient.png"), fig2, width = 8, height = 5, dpi = 300)


#fig3. Ratio of ADHD medication by deprivation 
rate_ratios <- final_rates %>%
  group_by(Year) %>%
  summarise(
    rate_most_deprived = treated_per_1000[IMD_num == 1],
    rate_least_deprived = treated_per_1000[IMD_num == 5],
    rate_ratio = rate_most_deprived / rate_least_deprived,
    .groups = "drop"
  )

fig3<-ggplot(rate_ratios, aes(x = Year, y = rate_ratio)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Ratio of ADHD medication treatment by deprivation",
    x = "Year",
    y = "Rate ratio (most vs least deprived)"
  ) +
  theme_minimal()
fig3
ggsave(here("outputs", "fig3_rate_ratio.png"), fig3, width = 8, height = 5, dpi = 300)


