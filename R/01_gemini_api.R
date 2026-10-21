# =============================================================================
# Generative AI Integration in R
# 01_gemini_api.R: the Google Gemini API from R with {ellmer}
# -----------------------------------------------------------------------------
# Author: Dax Mancilla
# Needs:  GEMINI_API_KEY in .Renviron (see 00_setup_api_keys.R)
# Shows:  conversation and token use, temperature and system prompts, and four
#         uses in data work: writing code, diagnosing data quality, explaining
#         a statistical result and returning structured output as a data frame
# =============================================================================

library(ellmer)
library(dplyr)

model <- "gemini-3.5-flash-lite"   # light and free-tier friendly; change if retired

# =============================================================================
# 1. A conversation keeps its memory
# =============================================================================
chat <- chat_google_gemini(model = model)

chat$chat("What is multicollinearity in a regression model?")
chat$chat("How do I detect it in R?")   # the object remembers the first question

chat$get_tokens()                       # input and output tokens used so far
chat                                     # printing the object shows the whole turn history

# =============================================================================
# 2. Temperature and system prompts
# =============================================================================
# Temperature controls how predictable the answer is:
#   0.0 to 0.2  code, data cleaning, statistical interpretation
#   0.3 to 0.5  report writing
#   0.6 to 0.8  exploring alternative charts or wordings
# The system prompt fixes the role and the format of every answer.

# =============================================================================
# 3. Uses in data work
# =============================================================================

# -----------------------------------------------------------------------------
# 3.1 Write R code
# -----------------------------------------------------------------------------
chat_code <- chat_google_gemini(
  model         = model,
  system_prompt = "Reply only with commented R code, without any other text.",
  params        = params(temperature = 0),
  echo          = "none"
)

code <- chat_code$chat(
  "Using the iris data set and ggplot2, draw a violin plot of Sepal.Length by
   Species and mark the mean of each species with a red point."
)
cat(code)   # always read and run the code yourself before using it

# -----------------------------------------------------------------------------
# 3.2 Diagnose data quality problems
# -----------------------------------------------------------------------------
data_raw <- data.frame(
  age    = c(25, "thirty", NA, 41),
  income = c(1500, 2300, 1800, NA),
  city   = c("lima", "Lima ", "LIMA", "lima")
)
str(data_raw)

chat_clean <- chat_google_gemini(model = model, params = params(temperature = 0), echo = "none")

diagnosis <- chat_clean$chat(paste(
  "This is the structure of a data frame with quality problems:",
  paste(capture.output(str(data_raw)), collapse = "\n"),
  "List each problem and the R function that fixes it.",
  sep = "\n"
))
cat(diagnosis)

# -----------------------------------------------------------------------------
# 3.3 Explain a statistical result to a non-technical reader
# -----------------------------------------------------------------------------
test <- t.test(mpg ~ am, data = mtcars)

chat_stats <- chat_google_gemini(
  model         = model,
  system_prompt = "You explain statistical results to people without technical
                   training. Do not claim causality. Do not invent figures: use
                   only the numbers you are given.",
  params        = params(temperature = 0.2),
  echo          = "none"
)

explanation <- chat_stats$chat(paste(
  "Explain this t-test in plain language, in five lines, and say which
   assumptions should be checked before trusting it:",
  paste(capture.output(test), collapse = "\n"),
  sep = "\n"
))
cat(explanation)

# -----------------------------------------------------------------------------
# 3.4 Structured output: from free text to a data frame
# -----------------------------------------------------------------------------
# $chat_structured() forces the model to return an exact shape. type_enum()
# restricts the possible labels, so the column can be grouped and counted.
comments <- c(
  "The delivery was late but the product is excellent",
  "Terrible service, I will not come back",
  "Everything was correct, nothing to report",
  "The online form worked, although the website is slow",
  "Very helpful staff at the counter"
)

chat_extract <- chat_google_gemini(model = model, params = params(temperature = 0), echo = "none")

classified <- chat_extract$chat_structured(
  paste("Classify each comment:", paste(comments, collapse = "\n"), sep = "\n"),
  type = type_array(
    type_object(
      comment   = type_string(description = "The original comment"),
      sentiment = type_enum(values = c("positive", "neutral", "negative"),
                            description = "Overall sentiment"),
      topic     = type_string(description = "Main topic in two words")
    )
  )
)

classified                          # a data frame
classified %>% count(sentiment)
