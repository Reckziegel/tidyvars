#' Tidy Residuals Test
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
#' tv_serial_test(model)
tv_serial_test <- function(x, ...) UseMethod("tv_serial_test", x)

#' @rdname tv_serial_test
#' @export
tv_serial_test.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_serial_test` method for objects of class", class(x), "."))
}

#' @rdname tv_serial_test
#' @export
tv_serial_test.varest <- function(x, ...) tidy_serial_test(x, ...)


#' @rdname tv_serial_test
#' @export
tv_serial_test.vec2var <- function(x, ...) tidy_serial_test(x, ...)
