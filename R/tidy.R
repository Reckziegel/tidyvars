# Tidy a VAR model
#
# Tidyier for the `varest` class.
#
# @param .x An object of the `varest` class.
# @param ... Additional objects to be pass through.
#
# @return A \code{tibble}.
# @export
#
# @examples
# model <- vars::VAR(EuStockMarkets)
# tidy(model)
#tidy <- function(.x, ...) broom::tidy(x = .x, ...)

#' @importFrom generics tidy
#' @export
generics::tidy
