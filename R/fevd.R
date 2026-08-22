#' Tidy forecast error variance decomposition
#'
#' Computes the forecast error variance decomposition using [vars::fevd()]
#' and converts the result to a tidy tibble.
#'
#' Each row represents the contribution of one shock to the forecast error
#' variance of one response variable at one forecast horizon.
#'
#' @param x A supported VAR model object. Currently supports objects of class
#'   `varest` and `vec2var`.
#' @param ... Additional arguments passed to [vars::fevd()], such as
#'   `n.ahead`.
#'
#' @return
#' A tibble with one row per response-shock-horizon combination and the
#' following columns:
#' \describe{
#'   \item{horizon}{Integer. Forecast horizon, starting at one.}
#'   \item{response}{Character. Variable whose forecast error variance is
#'   decomposed.}
#'   \item{shock}{Character. Shock contributing to the forecast error
#'   variance.}
#'   \item{contribution}{Double. Proportion of the forecast error variance
#'   attributable to the shock.}
#' }
#'
#' For `n.ahead = n`, the result contains horizons from `1` through `n`,
#' inclusive. For each combination of `horizon` and `response`, the
#' contributions across shocks sum to one, up to numerical precision.
#'
#' @seealso [vars::fevd()]
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_fevd(model, n.ahead = 5)
tv_fevd <- function(x, ...) {
  UseMethod("tv_fevd")
}

#' @rdname tv_fevd
#' @export
tv_fevd.default <- function(x, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_fevd} method for objects of class {.cls {class_name}}."
  )

}

#' @rdname tv_fevd
#' @export
tv_fevd.varest <- function(x, ...) {
  tidy_fevd_impl(x, ...)
}

#' @rdname tv_fevd
#' @export
tv_fevd.vec2var <- function(x, ...) {
  tidy_fevd_impl(x, ...)
}

#' Extract tidy forecast error variance decompositions
#'
#' @param x A supported VAR model object.
#' @param ... Additional arguments passed to [vars::fevd()].
#'
#' @return A `tv_fevd` tibble.
#' @keywords internal
tidy_fevd_impl <- function(x, ...) {

  fevd <- vars::fevd(x, ...)

  out <- purrr::imap_dfr(
    .x = fevd,
    .f = \(values, response_name) {

      values |>
        tibble::as_tibble() |>

        dplyr::mutate(
          horizon = seq_len(nrow(values)),
          response = response_name,
          .before = 1
        ) |>

        tidyr::pivot_longer(
          cols = -c(1, 2),
          names_to = "shock",
          values_to = "contribution"
        )
    }
  )

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_fevd"
  )

}
