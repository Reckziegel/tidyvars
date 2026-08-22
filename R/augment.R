#' Augment a VAR model
#'
#' Converts observed values, fitted values, and residuals from a supported
#' VAR model into a tidy tibble.
#'
#' Each row represents one variable at one observation of the original
#' time series.
#'
#' @param x A supported VAR model object.
#' @param ... Additional arguments passed to methods. Currently unused.
#'
#' @return
#' A tibble with one row per variable-observation pair and the following
#' columns:
#' \describe{
#'   \item{index}{Observation index from the original series.}
#'   \item{variable}{Character. Variable of the VAR.}
#'   \item{observed}{Double. Observed value.}
#'   \item{fitted}{Double. Fitted value.}
#'   \item{residual}{Double. Model residual.}
#' }
#'
#' Observations unavailable for model fitting because of the VAR lag
#' structure have `NA` in `fitted` and `residual`.
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' tv_augment(model)
tv_augment <- function(x, ...) {
  UseMethod("tv_augment")
}

#' @rdname tv_augment
#' @export
tv_augment.default <- function(x, ...) {
  class_name <- class(x)[[1]]
  cli::cli_abort(
    "No {.fn tv_augment} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_augment
#' @export
tv_augment.varest <- function(x, ...) {
  tidy_augment_impl(x)
}

#' @rdname tv_augment
#' @export
tv_augment.vec2var <- function(x, ...) {
  tidy_augment_impl(x)
}

#' Extract augmented values from a VAR model
#'
#' @param x A supported VAR model object.
#'
#' @return A `tv_augment` tibble.
#' @keywords internal
tidy_augment_impl <- function(x) {
  variable_names <- colnames(x$y)
  index <- augment_index(x$y)

  fitted_values <- stats::fitted(x)
  residual_values <- stats::residuals(x)

  n_fitted <- nrow(fitted_values)
  n_residuals <- nrow(residual_values)

  if (n_fitted != n_residuals) {
    cli::cli_abort(
      "Fitted values and residuals have incompatible numbers of observations."
    )
  }

  estimation_index <- utils::tail(index, n_fitted)

  observed <- augment_matrix_long(
    values = x$y,
    index = index,
    variable_names = variable_names,
    value_name = "observed"
  )

  fitted <- augment_matrix_long(
    values = fitted_values,
    index = estimation_index,
    variable_names = variable_names,
    value_name = "fitted"
  )

  residual <- augment_matrix_long(
    values = residual_values,
    index = estimation_index,
    variable_names = variable_names,
    value_name = "residual"
  )

  out <- observed |>
    dplyr::left_join(fitted, by = c("index", "variable")) |>
    dplyr::left_join(residual, by = c("index", "variable"))

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_augment"
  )

}

#' Convert a model matrix to long format
#'
#' @param values A numeric matrix.
#' @param index Observation indices.
#' @param variable_names Variable names.
#' @param value_name Name of the resulting value column.
#'
#' @return A tibble in long format.
#' @keywords internal
augment_matrix_long <- function(values, index, variable_names, value_name) {
  if (ncol(values) != length(variable_names)) {
    cli::cli_abort(
      "Model values have an incompatible number of variables."
    )
  }

  colnames(values) <- variable_names

  values |>
    tibble::as_tibble() |>
    dplyr::mutate(index = index, .before = 1) |>
    tidyr::pivot_longer(
      cols = -1,
      names_to = "variable",
      values_to = value_name
    )

}

#' Extract the observation index from model data
#'
#' @param y Original model data.
#'
#' @return An observation index.
#' @keywords internal
augment_index <- function(y) {
  n_obs <- nrow(y)

  if (!is.null(stats::tsp(y))) {
    return(as.numeric(stats::time(y)))
  }

  row_names <- rownames(y)
  default_row_names <- as.character(seq_len(n_obs))

  if (!is.null(row_names) && !identical(row_names, default_row_names)) {

    dates <- suppressWarnings(as.Date(row_names))

    if (all(!is.na(dates))) {
      return(dates)
    }

    return(row_names)

  }

  seq_len(n_obs)

}
