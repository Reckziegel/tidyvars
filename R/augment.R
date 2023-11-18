#' @importFrom generics augment
#' @export
generics::augment

#' Augment a VAR model
#'
#' Augment for the `varest` class.
#'
#' @param .x An object of the `varest` class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' augment(model)
augment.varest <- function(x, ...) {

  # extract original data
  y <- x$y |>
    tibble::as_tibble() |>
    tibble::rowid_to_column() |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = ".data")

  # extract fitted values
  fit <- fitted(x) |>
    tibble::as_tibble() |>
    tibble::rowid_to_column() |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = ".fitted")

  # extract residuals
  res <- residuals(x) |>
    tibble::as_tibble() |>
    tibble::rowid_to_column() |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = ".resid")

  purrr::reduce(.x = list(y, fit, res), .f = dplyr::left_join, by = c("rowid", ".asset"))

}

