# @importFrom generics augment
# @export
#generics::augment

#' Augment a VAR model
#'
#' Augment for the \code{varest} and \code{vec2var} class.
#'
#' @param x An object of the \code{varest} and \code{vec2var} class.
#' @param ... Additional objects to be pass through. Currently not used.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_augment(model)
tv_augment <- function(x, ...) UseMethod("tv_augment", x)

#' @rdname tv_augment
#' @export
tv_augment.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_augment` method for objects of class", class(x), "."))
}

#' @rdname tv_augment
#' @export
tv_augment.varest <- function(x, ...) {

  # extract original data
  y <- map_augment(x$y, values_to = ".x")
  # extract fitted values
  fit <- map_augment(stats::fitted(x), values_to = ".fitted")
  # extract residuals
  res <- map_augment(stats::residuals(x), values_to = ".resid")

  .out <- purrr::reduce(
    .x = list(y, fit, res),
    .f = dplyr::left_join,
    by = c("rowid", ".asset")
  )

  if (check_date_col(x) > 1) {

    dates <- lubridate::as_date(rownames(x$y))
    .out <- dplyr::mutate(.out, rowid = rep(dates, each = x$K))

  }

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_augment", .data = x)

}

#' @rdname tv_augment
#' @export
tv_augment.vec2var <- function(x, ...) {

  # extract original data
  y <- map_augment(x$y, values_to = ".x")
  # extract fitted values
  fit <- map_augment(stats::fitted(x), values_to = ".fitted")
  # extract residuals
  res <- map_augment(stats::residuals(x), values_to = ".resid")

  .out <- purrr::reduce(
    .x = list(y, fit, res),
    .f = dplyr::left_join,
    by = c("rowid", ".asset")
  )

  if (check_date_col(x) > 1) {

    dates <- lubridate::as_date(rownames(x$y))
    .out <- dplyr::mutate(.out, rowid = rep(dates, each = x$K))

  }

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_augment", .data = x)

}

