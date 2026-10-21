# Generative AI Integration in R: LLM APIs and Structured Output

Integration of large language models (LLMs) into R workflows for economic and statistical analysis, using the [`ellmer`](https://ellmer.tidyverse.org/) package. The scripts cover API access to Google Gemini and Groq, any OpenAI-compatible endpoint, structured output with typed schemas and AI-assisted coding with GitHub Copilot in RStudio. The material comes from a specialisation course on R with generative AI that I designed and taught.

## What each script does

| Script | Provider | What it shows |
|---|---|---|
| `R/00_setup_api_keys.R` | Gemini, Groq | Stores the API keys in `.Renviron` (never in the code) and tests the connections |
| `R/01_gemini_api.R` | Google Gemini | Conversations and token use, temperature and system prompts, writing R code, diagnosing data quality, explaining a statistical test without inventing figures, and structured output returned as a data frame |
| `R/02_groq_api.R` | Groq, NVIDIA NIM | Fast open-weight models, classification of citizen feedback into a data frame, response time, **checking the model's macroeconomic figures against the World Bank (WDI)**, and connecting to any OpenAI-compatible provider |
| `R/03_github_copilot.R` | GitHub Copilot | Comment-driven coding in RStudio with World Bank data: each task is written as a comment, Copilot proposes the code and the result is reviewed |

The scripts are kept separate because each one needs a different provider and key, and can be run on its own.

## Setup

1. Install the packages:
   ```r
   install.packages(c("ellmer", "usethis", "dplyr", "ggplot2", "WDI"))
   ```
2. Get free API keys from [Google AI Studio](https://aistudio.google.com/apikey) and [Groq](https://console.groq.com/keys) (NVIDIA is optional).
3. Copy the variable names from `.Renviron.example` into your personal `.Renviron` (`usethis::edit_r_environ()`), paste your keys and restart R.

Model names change and some are retired. If a model returns an error 404, replace it with a current one from the provider's catalogue.

## Responsible use

- **Never send confidential or personal microdata to an external API.**
- **Check every figure and every line of code** before using it. Section 4 of `02_groq_api.R` shows how far model answers can be from official statistics.
- Free tiers have rate limits per minute and per day. An error 429 means waiting before the next request.

## Repository structure

```
generative-ai-integration-r/
├── R/
│   ├── 00_setup_api_keys.R
│   ├── 01_gemini_api.R
│   ├── 02_groq_api.R
│   └── 03_github_copilot.R
└── .Renviron.example     # names of the API key variables
```

## Author

Dax Mancilla, economist (M.Sc. Applied Economics, Universidad Complutense de Madrid). [LinkedIn](https://linkedin.com/in/dax-mancilla-575b0814a)
