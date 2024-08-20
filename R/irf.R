#' Tidy Impulse-Response Function
#'
#' Tidier for the \code{varest}, \code{vec2var} and \code{svarest} class.
#'
#' @param x An object of the \code{varest}, \code{vec2var} and \code{svarest} class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_irf(model)
tv_irf <- function(x, ...) UseMethod("tv_irf", x)

#' @rdname tv_irf
#' @export
tv_irf.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_irf` method for objects of class", class(x), "."))
}

#' @rdname tv_irf
#' @export
tv_irf.varest <- function(x, ...) tidy_impulses(x, ...)

#' @rdname tv_irf
#' @export
tv_irf.vec2var <- function(x, ...) tidy_impulses(x, ...)

#' @rdname tv_irf
#' @export
tv_irf.svarest <- function(x, ...) tidy_impulses(x, ...)

