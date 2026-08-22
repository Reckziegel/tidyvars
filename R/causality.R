#' Tidy causality tests
#'
#' Computes Granger and instantaneous causality tests using
#' [vars::causality()] and converts the results to a tidy tibble.
#'
#' Each row represents one causality test for one variable considered as
#' the cause.
#'
#' @param x A `varest` model object.
#' @param ... Additional arguments passed to [vars::causality()], such as
#'   `vcov.`, `boot`, and `boot.runs`. The `cause` argument is managed
#'   internally by `tv_causality()`.
#'
#' @return
#' A tibble with one row per cause-test combination and the following
#' columns:
#' \describe{
#'   \item{cause}{Character. Variable considered as the cause.}
#'   \item{test}{Character. Type of causality test.}
#'   \item{statistic}{Double. Test statistic.}
#'   \item{df}{Double. Degrees of freedom when represented by one parameter.}
#'   \item{df1}{Double. Numerator degrees of freedom for an F test.}
#'   \item{df2}{Double. Denominator degrees of freedom for an F test.}
#'   \item{boot_runs}{Double. Number of bootstrap replications when the
#'   Granger test is bootstrapped.}
#'   \item{p_value}{Double. p-value associated with the test statistic.}
#'   \item{method}{Character. Description of the statistical test.}
#' }
#'
#' Parameter columns that do not apply to a given test are returned as `NA`.
#' For a non-bootstrapped Granger test, `df1` and `df2` are populated. For a
#' bootstrapped Granger test, `boot_runs` is populated instead. Instantaneous
#' causality uses `df`.
#'
#' @seealso [vars::causality()]
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_causality(model)
tv_causality <- function(x, ...) {
  UseMethod("tv_causality")
}

#' @rdname tv_causality
#' @export
tv_causality.default <- function(x, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_causality} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_causality
#' @export
tv_causality.varest <- function(x, ...) {
  tidy_causality_impl(x, ...)
}

#' Extract tidy causality tests
#'
#' @param x A `varest` model object.
#' @param ... Additional arguments passed to [vars::causality()].
#'
#' @return A `tv_causality` tibble.
#' @keywords internal
tidy_causality_impl <- function(x, ...) {

  causes <- names(stats::coef(x))

  out <- purrr::map_dfr(
    .x = causes,
    .f = \(cause) {

      causality <- vars::causality(x = x, cause = cause, ...)

      dplyr::bind_rows(
        tidy_causality_htest(
          causality$Granger,
          cause = cause,
          test = "granger"
        ),
        tidy_causality_htest(
          causality$Instant,
          cause = cause,
          test = "instantaneous"
        )
      )
    }
  )

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_causality"
  )
}

#' Convert a causality htest to one tidy row
#'
#' @param x An `htest` object.
#' @param cause Cause represented by the test.
#' @param test Test identifier.
#'
#' @return A one-row tibble.
#' @keywords internal
tidy_causality_htest <- function(x, cause, test) {

  tibble::tibble(
    cause     = cause,
    test      = test,
    statistic = as.numeric(x$statistic),
    df        = htest_parameter(x, "df"),
    df1       = htest_parameter(x, "df1"),
    df2       = htest_parameter(x, "df2"),
    boot_runs = htest_parameter(x, "boot.runs"),
    p_value   = as.numeric(x$p.value),
    method    = x$method
  )
}

#' Extract a named parameter from an htest object
#'
#' @param x An `htest` object.
#' @param parameter Parameter name.
#'
#' @return A double scalar or `NA_real_` when the parameter is absent.
#' @keywords internal
htest_parameter <- function(x, parameter) {
  parameters <- x$parameter

  if (is.null(parameters) || is.null(names(parameters)) || !parameter %in% names(parameters)) {
    return(NA_real_)
  }

  as.numeric(parameters[[parameter]])

}



