#' Tidy Prediction of a VAR Model
#'
#' Tidyier for the `varest` class.
#'
#' @param x An object of the `varest` class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' tv_predict(model)
tv_predict <- function(x, ...) UseMethod("tv_predict", x)

#' @rdname tv_predict
#' @export
tv_predict.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_predict` method for objects of class", class(x), "."))
}

#' @rdname tv_predict
#' @export
tv_predict.varest <- function(x, ...) {

  pred <- stats::predict(x, ...)

  .out <- purrr::map(pred$fcst, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".asset") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .asset, dplyr::everything())

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_predict", .data = pred$endog)

}

