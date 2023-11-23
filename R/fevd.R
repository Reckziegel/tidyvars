#' Tidy Forecast Error Variance Decomposition
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
#' tv_fevd(model)
tv_fevd <- function(x, ...) UseMethod("tv_fevd", x)

#' @rdname tv_fevd
#' @export
tv_fevd.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_fevd` method for objects of class", class(x), "."))
}

#' @rdname tv_fevd
#' @export
tv_fevd.varest <- function(x, ...) {

  .fevd <- vars::fevd(x, ...)

  .out <- purrr::map(.fevd, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".asset") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .asset, dplyr::everything()) |>
    tidyr::pivot_longer(cols = -c("rowid", ".asset"), names_to = ".impact", values_to = ".fevd")

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_fevd")

}

#' @rdname tv_fevd
#' @export
tv_fevd.vec2var <- function(x, ...) {

  .fevd <- vars::fevd(x, ...)

  .out <- purrr::map(.fevd, tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".asset") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .asset, dplyr::everything()) |>
    tidyr::pivot_longer(cols = -c("rowid", ".asset"), names_to = ".impact", values_to = ".fevd")

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_fevd")

}
