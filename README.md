# A Closing Gap? Socioeconomic Deprivation and ADHD Medication Use in England, 2016–2024
An independent research project examining whether the use of ADHD medication in England differs across levels of area deprivation, and whether these differences have changed over time.
 

---
 
## Background

Attention deficit hyperactivity disorder (ADHD) is one of the most common neurodevelopmental conditions, and medication is a recommended part of treatment for many children and adults when symptoms cause significant impairment (NICE, 2018). Over the past two decades, ADHD diagnosis and treatment in the UK have risen sharply. Between 2000 and 2018, new diagnoses in UK primary care roughly doubled in boys and quadrupled in girls, while increases among adults were far larger, at about 20-fold in men and 15-fold in women (McKechnie et al., 2023). Growth accelerated after 2020, where adult ADHD referrals tripled between 2020 and 2023 (Shah et al., 2026), and community prescribing of ADHD medication in England rose by an average of 18% per year between 2019/20 and 2023/24 (Khan & Hasan, 2025). Demand has outpaced NHS capacity, and in 2022–24 children waited an average of 2 years 5 months from referral to an ADHD diagnosis in community services (Children's Commissioner for England, 2024).

This rapid expansion raises the question of who has benefited from it. ADHD is known to be patterned by socioeconomic disadvantage. Children from lower-income families are more likely to have ADHD, and this reflects a genuine difference in symptoms, not over-diagnosis of poorer families (Russell et al, 2014). However, need does not translate equally into treatment. Children from the least advantaged families who had been diagnosed with ADHD were much less likely to receive medication than those from more advantaged families (Pearce et al, 2024). Long NHS waits have also increased the use of private and Right to Choose assessment routes, which may be easier to navigate for those with more resources (Children's Commissioner for England, 2024).

Earlier studies found that ADHD diagnosis and prescribing were higher in more deprived areas (McKechnie et al, 2023; Khan & Hasan, 2025). These studies did not examine how the deprivation gradient changed during the recent surge in treatment. Data from before 2018 cannot capture the post-pandemic period, and analyses at the level of large health-system areas (integrated care boards) treat deprivation as a fixed characteristic and may average out differences between neighbourhoods. Whether the recent growth in ADHD medication has narrowed, maintained or widened socioeconomic inequalities in treatment is therefore unclear.

---

### Aim

This project examines how socioeconomic inequalities in ADHD medication use changed in England between 2016 and 2024. Specifically, it asks:

1. How did rates of ADHD medication use differ by small-area deprivation (IMD2025 quintile) in 2016?
2. Did the gap between the most and least deprived areas change over time?
3. Are these patterns explained by differences in the age structure of more and less deprived areas?

---

## Data
| Source | Description |
|---|---|
| **NHS Business Services Authority (NHSBSA)** | Medicines Used in Mental Health - BNF 0404 Central nervous system (CNS) stimulants and drugs used for ADHD, (2016-2024) |
| **Office for National Statistics (ONS)** | Mid-year population estimates (2016-2024), used as denominators to calculate utilisation rates |
| **English Indices of Deprivation** | Index of Multiple Deprivation (IMD) (2019) quintiles, from 1 (most deprived) to 5 (least deprived) |

---

## Key findings
 
- ADHD medication use **increased in every IMD quintile** between 2016 and 2024.
- In 2016, treatment rates were **about twice as high in the most deprived areas** as in the least deprived (3.03 vs 1.57 per 1,000; rate ratio 1.93).
- The gap **narrowed every year**, because use grew faster in less deprived areas. By 2024 rates were almost equal (5.70 vs 5.48 per 1,000; rate ratio 1.04). Each quintile's rate grew more slowly than the least deprived quintile's (Q1 vs Q5 interaction IRR 0.92, 95% CI 0.91–0.94).
- **Age structure explained part of the 2016 gap** (age-adjusted Q1 vs Q5 rate ratio 1.60), but **not the narrowing over time**, which was unchanged after age adjustment and in the sensitivity analysis.
- Because ADHD is more common in deprived groups, similar treatment rates may mean that people in deprived areas are now treated less relative to need. See the [full report](Results.md) for discussion and limitations.

---

## Methods
 
1. **Data preparation:** NHSBSA prescribing data were linked with ONS population estimates by IMD quintile and year to calculate utilisation rates per 1,000 population.
2. **Descriptive analysis:** Crude treatment rates per 1,000 population by year and quintile, absolute (Q1 − Q5 rate difference) and relative (Q1 / Q5 rate ratio) inequality by year.
3. **Statistical analysis:** Negative binomial regression of patient counts with log(population) as an offset, giving incidence rate ratios (IRRs). Poisson models were fitted first and showed substantial overdispersion. Model selection used likelihood ratio tests and AIC:
- IMD quintile × linear year interaction (tests whether the deprivation gap changed over time)
- common quadratic year term (non-linear time trend)
- quintile-specific quadratic terms (not retained)

The final model included IMD quintile, linear year, their interaction, and a common quadratic year term. A sensitivity analysis replaced the time trend with year as a categorical variable.

---

## Code
Run scripts in order:
1. `01_prepare_prescribing_data.R` – cleans prescribing data
2. `02_population_by_imd25.R` – builds population by IMD2025 quintile
3. `06_analysis_dataset.R` – joins and calculates rates
4. `07_descriptive_analysis.R` – figures
5. `08_poisson_regression.R` – negative binomial models

## Requirements
R packages: tidyverse, readxl, here, broom, MASS

**Files**
data/raw/        – input files (not tracked)
data/processed/  – cleaned outputs
outputs/         – figures and model tables

---

## Key findings
 
- ADHD medication utilisation **increased across all IMD quintiles** between 2016 and 2024.
- Utilisation was **initially higher in more deprived areas**, but this gap **narrowed over time**, as utilisation increased faster in less deprived areas.

---

## References
 
Children's Commissioner for England. *Waiting times for assessment and support for autism, ADHD and other neurodevelopmental conditions.* 2024.
 
Khan MU, Hasan SS. Socioeconomic status and prescribing of ADHD medications: a study of ICB-level data in England. *BMJ Mental Health*. 2025;28:e301384. doi:10.1136/bmjment-2024-301384
 
McKechnie DGJ, O'Nions E, Dunsmuir S, Petersen I. Attention-deficit hyperactivity disorder diagnoses and prescriptions in UK primary care, 2000–2018: population-based cohort study. *BJPsych Open*. 2023;9(4):e121. doi:10.1192/bjo.2023.512
 
National Institute for Health and Care Excellence. *Attention deficit hyperactivity disorder: diagnosis and management* (NG87). 2018.
 
Pearce A, Henery P, Katikireddi SV, et al. Childhood attention-deficit hyperactivity disorder: socioeconomic inequalities in symptoms, impact, diagnosis and medication. *Child and Adolescent Mental Health*. 2024. doi:10.1111/camh.12707
 
Russell G, Ford T, Rosenberg R, Kelly S. The association of attention deficit hyperactivity disorder with socioeconomic disadvantage: alternative explanations and evidence. *Journal of Child Psychology and Psychiatry*. 2014;55(5):436–445. doi:10.1111/jcpp.12170
 
Shah P, Adamou M, Cape A, et al. Potential impact of social media and COVID-19 restrictions on adult attention-deficit rates. *BJPsych Bulletin*. 2026;50(3):230–237. doi:10.1192/bjb.2025.10162
