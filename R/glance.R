#' Glance a VAR model
#'
#' Tidyier for the `varest` class.
#'
#' @param .x An object of the `varest` class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' tv_glance(model)
tv_glance <- function(.x, ...) {
  .out <- broom::glance(x = .x, ...)
  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_glance")
}

# @importFrom generics glance
# @export
#generics::glance
