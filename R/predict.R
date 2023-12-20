#' Tidy Predict
#'
#' Tidier for the \code{varest} class.
#'
#' @param x An object of the \code{varest} class.
#' @param n.ahead The number of periods ahead in which the prediction should be made.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' tv_predict(model, n.ahead = 12)
tv_predict <- function(x, n.ahead, ...) UseMethod("tv_predict", x)

#' @rdname tv_predict
#' @export
tv_predict.default <- function(x, n.ahead, ...) {
  rlang::abort(message = paste0("No `tv_predict` method for objects of class", class(x), "."))
}

#' @rdname tv_predict
#' @export
tv_predict.varest <- function(x, n.ahead, ...) {

  assertthat::assert_that(assertthat::is.number(n.ahead))

  pred <- stats::predict(x, n.ahead = n.ahead, ...)

  .out <- purrr::map(pred$fcst, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".asset") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .asset, dplyr::everything())

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_predict", .data = pred$endog, ...)

}

