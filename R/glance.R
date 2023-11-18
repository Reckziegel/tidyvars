# Glance a VAR model
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
# glance(model)
#glance <- function(.x, ...) broom::glance(x = .x, ...)

#' @importFrom generics glance
#' @export
generics::glance
