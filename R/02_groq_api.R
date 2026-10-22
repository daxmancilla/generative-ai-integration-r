# =============================================================================
# Generative AI Integration in R
# 02_groq_api.R: fast open-weight models with Groq, and any OpenAI-compatible
#                provider from R
# -----------------------------------------------------------------------------
# Author: Dax Mancilla
# Needs:  GROQ_API_KEY in .Renviron; NVIDIA_API_KEY only for section 5
# Shows:  multi-turn conversations, structured classification, response time,
#         checking model figures against official data (World Bank WDI) and
#         connecting to a provider without its own {ellmer} function
# =============================================================================

library(ellmer)
library(dplyr)
library(WDI)

model_large <- "openai/gpt-oss-120b"
model_small <- "openai/gpt-oss-20b"

models_groq()   # available models and price per million input and output tokens

# =============================================================================
# 1. A short tutoring conversation
# =============================================================================
tutor <- chat_groq(
  model         = model_small,
  system_prompt = "You are a statistics tutor. Answer in at most 80 words."
)

tutor$chat("What is a p-value?")
tutor$chat("And what does it mean if it is below 0.05?")
tutor$chat("Give me an example with a t-test in R.")
tutor$get_tokens()

# =============================================================================
# 2. Classify citizen feedback into a data frame
# =============================================================================
feedback <- c(
  "The staff at the health centre were quick and kind.",
  "I waited three hours and nobody attended me.",
  "The online procedure worked, although the page is slow.",
  "Excellent guidance from the counter staff.",
  "Nobody could tell me which documents I needed.",
  "The service was correct, nothing to highlight."
)

classifier <- chat_groq(model = model_large, params = params(temperature = 0), echo = "none")

classified <- classifier$chat_structured(
  paste("Classify each comment:", paste(feedback, collapse = "\n"), sep = "\n"),
  type = type_array(type_object(
    comment   = type_string(),
    sentiment = type_enum(values = c("positive", "neutral", "negative")),
    topic     = type_string(description = "Main topic in two or three words")
  ))
)

classified
classified %>% count(sentiment)
classifier$get_tokens()

# =============================================================================
# 3. Response time
# =============================================================================
timer <- chat_groq(model = model_small, echo = "none")
elapsed <- system.time(
  timer$chat("Explain linear regression in about 300 words.")
)["elapsed"]
elapsed            # seconds for the full answer
timer$get_tokens()

# =============================================================================
# 4. Do not trust the numbers: check them against official data
# =============================================================================
# A model can return plausible but wrong figures. Ask for 2023 indicators in a
# structured form and compare them with the World Bank (WDI).
asked <- chat_groq(model = model_large, params = params(temperature = 0), echo = "none")

from_model <- asked$chat_structured(
  "For Peru, Chile, Colombia, Mexico and Argentina, give the annual inflation
   rate, real GDP growth and unemployment rate for 2023, in percent.",
  type = type_array(type_object(
    iso3c        = type_string(description = "ISO3 country code, for example PER"),
    inflation    = type_number(description = "Annual inflation 2023, %"),
    gdp_growth   = type_number(description = "Real GDP growth 2023, %"),
    unemployment = type_number(description = "Unemployment rate 2023, %")
  ))
)

official <- WDI(
  country   = c("PE", "CL", "CO", "MX", "AR"),
  indicator = c(inflation    = "FP.CPI.TOTL.ZG",
                gdp_growth   = "NY.GDP.MKTP.KD.ZG",
                unemployment = "SL.UEM.TOTL.ZS"),
  start = 2023, end = 2023
) %>%
  select(iso3c, country, inflation, gdp_growth, unemployment)

comparison <- official %>%
  inner_join(from_model, by = "iso3c", suffix = c("_wdi", "_model")) %>%
  mutate(across(c(inflation_wdi, gdp_growth_wdi, unemployment_wdi), ~ round(.x, 1)),
         gap_inflation    = round(inflation_model - inflation_wdi, 1),
         gap_gdp_growth   = round(gdp_growth_model - gdp_growth_wdi, 1),
         gap_unemployment = round(unemployment_model - unemployment_wdi, 1))

comparison %>% select(country, starts_with("gap_"))
# Any gap different from zero is a figure that should not go into a report
# without checking the source.

# =============================================================================
# 5. Any OpenAI-compatible provider (example: NVIDIA NIM)
# =============================================================================
# Providers without their own function in {ellmer} work through
# chat_openai_compatible(), with the provider's address and key.

# The NVIDIA catalogue is public: check which models are available today
nvidia_models <- jsonlite::fromJSON("https://integrate.api.nvidia.com/v1/models")$data
nvidia_models %>% filter(grepl("nemotron|deepseek|gpt-oss", id)) %>% select(id, owned_by)

savings_model <- lm(sr ~ pop15 + pop75 + dpi + ddpi, data = LifeCycleSavings)
output <- paste(capture.output(summary(savings_model)), collapse = "\n")

nvidia <- chat_openai_compatible(
  base_url    = "https://integrate.api.nvidia.com/v1",
  name        = "NVIDIA NIM",
  credentials = function() Sys.getenv("NVIDIA_API_KEY"),
  model       = "deepseek-ai/deepseek-v4.1-flash"   # must be in the list above
)

nvidia$chat(paste(
  "Interpret, in at most 120 words, the coefficients that are significant at 5%.",
  "sr is the savings rate; pop15 and pop75 the share of population under 15 and",
  "over 75; dpi real disposable income per capita; ddpi its growth rate.",
  "Do not claim causality.",
  output, sep = "\n"
))
