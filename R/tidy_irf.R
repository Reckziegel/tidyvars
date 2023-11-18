#' Tidy IRF for a VAR Model
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
#' tidy_irf(model)
tidy_irf <- function(x, ...) UseMethod("tidy_irf", x)

#' @rdname tidy_irf
#' @export
tidy_irf.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tidy_irf` method for objects of class", class(x), "."))
}

#' @rdname tidy_irf
#' @export
tidy_irf.varest <- function(x, ...) {

  impulse <- vars::irf(x, ...)

  purrr::map(impulse$irf, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".impulse") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .impulse, dplyr::everything()) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".irf")

}
