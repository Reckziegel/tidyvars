#' Tidy Normality Test
#'
#' Tidier for the \code{varest} and \code{vec2var} class.
#'
#' @param x An object of the \code{varest} and \code{vec2var} class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_normality_test(model)
tv_normality_test <- function(x, ...) UseMethod("tv_normality_test", x)

#' @rdname tv_normality_test
#' @export
tv_normality_test.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_normality_test` method for objects of class", class(x), "."))
}

#' @rdname tv_normality_test
#' @export
tv_normality_test.varest <- function(x, ...) tidy_normality_test(x, ...)

#' @rdname tv_normality_test
#' @export
tv_normality_test.vec2var <- function(x, ...) tidy_normality_test(x, ...)
