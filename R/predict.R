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
#' tv_predict(model, n.ahead = 12, ci = 0.5) # confidence internal = 50%
tv_predict <- function(x, n.ahead, ...) UseMethod("tv_predict", x)

#' @rdname tv_predict
#' @export
tv_predict.default <- function(x, n.ahead, ...) {
  rlang::abort(message = paste0("No `tv_predict` method for objects of class ", class(x), "."))
}

#' @rdname tv_predict
#' @export
tv_predict.varest <- function(x, n.ahead, ...) {
  assertthat::assert_that(assertthat::is.number(n.ahead))

  # 1. Tidy History
  history <- map_augment(x$y, values_to = ".x") |>
    dplyr::mutate(
      type = "history",
      fcst = NA_real_,
      lower = NA_real_,
      upper = NA_real_
    )

  # 2. Tidy Forecast
  pred <- stats::predict(x, n.ahead = n.ahead, ...)
  assets <- names(pred$fcst)

  is_date <- check_date_col(x) > 1

  if (is_date) {
    dates_vec <- lubridate::as_date(rownames(x$y))
    forecast_rowids <- check_time_interval(dates_vec, n.ahead)
  } else {
    n_hist <- nrow(x$y)
    forecast_rowids <- seq_len(n.ahead) + n_hist
  }

  forecast <- purrr::map_df(assets, function(a) {
    tibble::tibble(
      rowid = forecast_rowids,
      .asset = a,
      .x = pred$fcst[[a]],
      fcst = pred$fcst[[a]],
      lower = pred$lower[[a]],
      upper = pred$upper[[a]],
      type = "forecast"
    )
  })

  # 3. Combine
  combined <- dplyr::bind_rows(history, forecast) |>
    dplyr::arrange(rowid, .asset)

  tibble::as_tibble(combined, class = c("tv_predict", class(combined)))
}
