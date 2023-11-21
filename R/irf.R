#' Tidy IRF for a VAR Model
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
tv_irf.varest <- function(x, ...) {

  impulse <- vars::irf(x, ...)

  .irf <- map_irf(impulse$irf) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".irf")

  .lower <- map_irf(impulse$Lower) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".lower")

  .upper <- map_irf(impulse$Upper) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".upper")

  .out <- purrr::reduce(
    .x = list(.irf, .lower, .upper),
    .f = dplyr::left_join,
    by = c("rowid", ".impulse", ".asset")
  )

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_irf")

}

#' @rdname tv_irf
#' @export
tv_irf.vec2var <- function(x, ...) {

  impulse <- vars::irf(x, ...)

  .irf <- map_irf(impulse$irf) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".irf")

  .lower <- map_irf(impulse$Lower) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".lower")

  .upper <- map_irf(impulse$Upper) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".upper")

  .out <- purrr::reduce(
    .x = list(.irf, .lower, .upper),
    .f = dplyr::left_join,
    by = c("rowid", ".impulse", ".asset")
  )

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_irf")

}

#' @rdname tv_irf
#' @export
tv_irf.svarest <- function(x, ...) {

  impulse <- vars::irf(x, ...)

  .irf <- map_irf(impulse$irf) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".irf")

  .lower <- map_irf(impulse$Lower) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".lower")

  .upper <- map_irf(impulse$Upper) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = ".upper")

  .out <- purrr::reduce(
    .x = list(.irf, .lower, .upper),
    .f = dplyr::left_join,
    by = c("rowid", ".impulse", ".asset")
  )

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_irf")

}
