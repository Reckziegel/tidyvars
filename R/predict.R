#' Tidy Prediction of a VAR Model
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
#' tidy_predict(model)
tidy_predict <- function(x, ...) UseMethod("tidy_predict", x)

#' @rdname tidy_predict
#' @export
tidy_predict.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tidy_predict` method for objects of class", class(x), "."))
}

#' @rdname tidy_predict
#' @export
tidy_predict.varest <- function(x, ...) {

  pred <- stats::predict(x, ...)

  purrr::map(pred$fcst, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".asset") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .asset, dplyr::everything())

}

