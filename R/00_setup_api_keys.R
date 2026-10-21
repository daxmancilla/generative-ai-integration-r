# =============================================================================
# Generative AI Integration in R
# 00_setup_api_keys.R: store the API keys once and test the connections
# -----------------------------------------------------------------------------
# Author: Dax Mancilla
# =============================================================================
# API keys never go inside the scripts. They are stored in .Renviron, a
# personal file outside the project that R reads every time it starts.
# Add one line per provider (no quotes), following .Renviron.example:
#
#   GEMINI_API_KEY=your_key    free key at https://aistudio.google.com/apikey
#   GROQ_API_KEY=your_key      free key at https://console.groq.com/keys
#   NVIDIA_API_KEY=your_key    optional, https://build.nvidia.com
#
# Save the file and restart R (Session > Restart R, or Ctrl + Shift + F10).
# =============================================================================

# install.packages(c("ellmer", "usethis"))
usethis::edit_r_environ()

library(ellmer)

# Connection tests: each call should answer "ready"
gemini <- chat_google_gemini(model = "gemini-3.5-flash-lite", echo = "none")
gemini$chat("Reply only with the word: ready")

groq <- chat_groq(model = "openai/gpt-oss-20b", echo = "none")
groq$chat("Reply only with the word: ready")

# -----------------------------------------------------------------------------
# Common errors
# -----------------------------------------------------------------------------
# "API key not valid"         the key was copied incomplete.
# HTTP 404                    the model is not available for new accounts or
#                             was retired: change the model name.
# HTTP 429 Too Many Requests  free-tier rate limit (requests or tokens per
#                             minute). Wait a minute and try again.
