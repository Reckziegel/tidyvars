#' Tidy impulse-response functions
#'
#' Computes impulse-response functions using [vars::irf()] and converts the
#' result to a tidy tibble.
#'
#' Each row represents the response of one variable to one impulse at one
#' horizon.
#'
#' @param x A supported VAR model object. Currently supports objects of class
#'   `varest`, `vec2var`, and `svarest`.
#' @param ... Additional arguments passed to [vars::irf()], such as `impulse`,
#'   `response`, `n.ahead`, `ortho`, `cumulative`, `boot`, `ci`, `runs`, and
#'   `seed`.
#'
#' @return
#' A tibble with one row per impulse-response-horizon combination and the
#' following columns:
#' \describe{
#'   \item{horizon}{Integer. Horizon of the impulse response, starting at zero.}
#'   \item{impulse}{Character. Variable receiving the shock.}
#'   \item{response}{Character. Variable responding to the shock.}
#'   \item{estimate}{Double. Estimated impulse-response coefficient.}
#'   \item{lower}{Double. Lower bootstrap confidence bound.}
#'   \item{upper}{Double. Upper bootstrap confidence bound.}
#' }
#'
#' When `boot = FALSE`, `lower` and `upper` are returned as `NA`.
#'
#' For `n.ahead = n`, the result contains horizons from `0` through `n`,
#' inclusive.
#'
#' @seealso [vars::irf()]
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_irf(
#'   model,
#'   impulse = "DAX",
#'   response = "SMI",
#'   n.ahead = 5,
#'   boot = FALSE
#' )
tv_irf <- function(x, ...) {
  UseMethod("tv_irf")
}

#' @rdname tv_irf
#' @export
tv_irf.default <- function(x, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_irf} method for objects of class {.cls {class_name}}."
  )

}

#' @rdname tv_irf
#' @export
tv_irf.varest <- function(x, ...) {
  tidy_irf_impl(x, ...)
}

#' @rdname tv_irf
#' @export
tv_irf.vec2var <- function(x, ...) {
  tidy_irf_impl(x, ...)
}

#' @rdname tv_irf
#' @export
tv_irf.svarest <- function(x, ...) {
  tidy_irf_impl(x, ...)
}

#' Extract tidy impulse-response functions
#'
#' @param x A supported model object.
#' @param ... Additional arguments passed to [vars::irf()].
#'
#' @return A `tv_irf` tibble.
#' @keywords internal
tidy_irf_impl <- function(x, ...) {

  irf <- vars::irf(x, ...)
  out <- tidy_irf_component(irf$irf, value_name = "estimate")

  if (isTRUE(irf$boot)) {

    lower <- tidy_irf_component(irf$Lower, value_name = "lower")
    upper <- tidy_irf_component(irf$Upper, value_name = "upper")

    out <- out |>
      dplyr::left_join(
        lower,
        by = c("horizon", "impulse", "response")
      ) |>
      dplyr::left_join(
        upper,
        by = c("horizon", "impulse", "response")
      )

  } else {

    out <- out |>
      dplyr::mutate(lower = NA_real_, upper = NA_real_)

  }

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_irf"
  )

}

#' Convert an impulse-response component to long format
#'
#' @param x A named list of impulse-response matrices.
#' @param value_name Name of the resulting value column.
#'
#' @return A tibble in long format.
#' @keywords internal
tidy_irf_component <- function(x, value_name) {

  purrr::imap_dfr(
    .x = x,
    .f = \(values, impulse_name) {

      values |>
        tibble::as_tibble() |>

        dplyr::mutate(
          horizon = seq.int(0L, nrow(values) - 1L),
          .before = 1
        ) |>

        tidyr::pivot_longer(
          cols = -1,
          names_to = "response",
          values_to = value_name
        ) |>

        dplyr::mutate(
          impulse = .env$impulse_name,
          .after = "horizon"
        )
    }
  )

}
