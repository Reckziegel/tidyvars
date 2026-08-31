# Global imports for tidyverse pronouns
#' @importFrom rlang .data .env
NULL

.onLoad <- function(...) {
  S7::methods_register()
}
