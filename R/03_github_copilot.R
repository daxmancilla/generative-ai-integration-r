# =============================================================================
# Generative AI Integration in R
# 03_github_copilot.R: comment-driven coding with GitHub Copilot in RStudio
# -----------------------------------------------------------------------------
# Author: Dax Mancilla
# Setup:  RStudio > Tools > Global Options > Copilot > Enable GitHub Copilot,
#         then sign in with a GitHub account that has Copilot (there is a free
#         plan). Copilot suggests code in grey; Tab accepts it.
# Method: each task is written as a comment with the object name, variables
#         and expected output. Copilot proposes the code below the comment,
#         which is then reviewed, run and corrected where needed.
# Data:   World Development Indicators (World Bank), 2024
# =============================================================================

library(dplyr)
library(ggplot2)
library(WDI)

# Download life expectancy, health spending, population, Gini and GDP per
# capita for all countries in 2024 into base_wb, with region and income group
base_wb <- WDI(
  country   = "all",
  indicator = c(life_expectancy = "SP.DYN.LE00.IN",
                health_spending = "SH.XPD.CHEX.GD.ZS",
                population      = "SP.POP.TOTL",
                gini            = "SI.POV.GINI",
                gdp_pc          = "NY.GDP.PCAP.CD"),
  start = 2024, end = 2024, extra = TRUE
)

# -----------------------------------------------------------------------------
# Level 1: exploration
# -----------------------------------------------------------------------------

# Drop the regional aggregates (region "Aggregates" or missing) into base_wb_clean
base_wb_clean <- base_wb %>%
  filter(!is.na(region) & region != "Aggregates")

# Mean, number of countries with data, median, standard deviation and
# coefficient of variation of life expectancy by region, in table_region
table_region <- base_wb_clean %>%
  group_by(region) %>%
  summarise(
    mean   = mean(life_expectancy, na.rm = TRUE),
    n      = sum(!is.na(life_expectancy)),
    median = median(life_expectancy, na.rm = TRUE),
    sd     = sd(life_expectancy, na.rm = TRUE),
    cv     = 100 * sd / mean
  ) %>%
  arrange(desc(mean))
table_region

# -----------------------------------------------------------------------------
# Level 2: charts
# -----------------------------------------------------------------------------

# Bubble chart of GDP per capita (log scale) and life expectancy, bubble size
# by population and colour by region, in chart_bubbles
chart_bubbles <- ggplot(base_wb_clean,
                        aes(x = gdp_pc, y = life_expectancy, size = population, colour = region)) +
  geom_point(alpha = 0.7) +
  scale_x_log10(labels = scales::label_dollar()) +
  scale_size(range = c(1, 15), guide = "none") +
  labs(title = "GDP per capita and life expectancy, 2024",
       x = "GDP per capita (current US$, log scale)", y = "Life expectancy (years)",
       colour = "Region") +
  theme_minimal()
chart_bubbles

# Box plot of life expectancy by income group, ordered from low to high
# income, in chart_income
chart_income <- base_wb_clean %>%
  filter(income != "Not classified") %>%
  mutate(income = factor(income, levels = c("Low income", "Lower middle income",
                                            "Upper middle income", "High income"))) %>%
  ggplot(aes(x = income, y = life_expectancy, fill = income)) +
  geom_boxplot() +
  labs(title = "Life expectancy by income group, 2024", x = NULL, y = "Years") +
  theme_minimal() +
  theme(legend.position = "none")
chart_income
