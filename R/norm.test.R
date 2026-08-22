#' Tidy VAR normality tests
#'
#' Computes normality tests for the residuals of a supported VAR model using
#' [vars::normality.test()] and converts the results to a tidy tibble.
#'
#' Each row represents one normality test applied either to the residuals of
#' the VAR jointly or to the residuals of one equation.
#'
#' @param x A supported VAR model object. Currently supports objects of class
#'   `varest` and `vec2var`.
#' @param ... Additional arguments passed to [vars::normality.test()], such as
#'   `multivariate.only`.
#'
#' @return
#' A tibble with one row per normality test and the following columns:
#' \describe{
#'   \item{scope}{Character. Scope of the test: `"multivariate"` or
#'   `"univariate"`.}
#'   \item{variable}{Character. Variable associated with a univariate test.
#'   `NA` for multivariate tests.}
#'   \item{test}{Character. Test identifier: `"jarque_bera"`, `"skewness"`,
#'   or `"kurtosis"`.}
#'   \item{statistic}{Double. Test statistic.}
#'   \item{df}{Double. Degrees of freedom.}
#'   \item{p_value}{Double. p-value associated with the test statistic.}
#'   \item{method}{Character. Description of the statistical test.}
#' }
#'
#' With the default `multivariate.only = TRUE`, only the multivariate
#' Jarque-Bera, skewness, and kurtosis tests are returned. When
#' `multivariate.only = FALSE`, the result also includes one univariate
#' Jarque-Bera test for each equation of the model.
#'
#' @seealso [vars::normality.test()]
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_normality_test(model)
#'
#' tv_normality_test(
#'   model,
#'   multivariate.only = FALSE
#' )
tv_normality_test <- function(x, ...) {
  UseMethod("tv_normality_test")
}

#' @rdname tv_normality_test
#' @export
tv_normality_test.default <- function(x, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    paste0(
      "No {.fn tv_normality_test} method for objects of class ",
      "{.cls {class_name}}."
    )
  )
}

#' @rdname tv_normality_test
#' @export
tv_normality_test.varest <- function(x, ...) {
  tidy_normality_test(x, ...)
}

#' @rdname tv_normality_test
#' @export
tv_normality_test.vec2var <- function(x, ...) {
  tidy_normality_test(x, ...)
}

#' Extract tidy normality tests
#'
#' @param x A supported VAR model object.
#' @param ... Additional arguments passed to [vars::normality.test()].
#'
#' @return A `tv_normality_test` tibble.
#' @keywords internal
tidy_normality_test <- function(x, ...) {
  normality <- vars::normality.test(x, ...)

  multivariate <- tidy_multivariate_normality(normality$jb.mul)

  if (is.null(normality$jb.uni)) {
    out <- multivariate
  } else {
    univariate <- tidy_univariate_normality(
      normality$jb.uni,
      variable_names = colnames(normality$resid)
    )

    out <- dplyr::bind_rows(
      multivariate,
      univariate
    )
  }

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_normality_test"
  )
}

#' Tidy multivariate normality tests
#'
#' @param tests A named list of multivariate normality tests.
#'
#' @return A tibble.
#' @keywords internal
tidy_multivariate_normality <- function(tests) {

  purrr::imap_dfr(
    .x = tests,
    .f = \(test_result, test_name) {

      tibble::tibble(
        scope     = "multivariate",
        variable  = NA_character_,
        test      = normality_test_name(test_name),
        statistic = as.numeric(test_result$statistic),
        df        = htest_parameter(test_result, "df"),
        p_value   = as.numeric(test_result$p.value),
        method    = test_result$method
      )
    }

  )

}

#' Tidy univariate normality tests
#'
#' @param tests A list of univariate normality tests.
#' @param variable_names Names of the model variables.
#'
#' @return A tibble.
#' @keywords internal
tidy_univariate_normality <- function(tests, variable_names) {

  test_names <- names(tests)

  if (is.null(test_names) || length(test_names) != length(tests) || any(test_names == "")) {
    test_names <- variable_names
  }

  purrr::map2_dfr(
    .x = tests,
    .y = test_names,
    .f = \(test_result, variable_name) {

      tibble::tibble(
        scope     = "univariate",
        variable  = variable_name,
        test      = "jarque_bera",
        statistic = as.numeric(test_result$statistic),
        df        = htest_parameter(test_result, "df"),
        p_value   = as.numeric(test_result$p.value),
        method    = test_result$method
      )
    }
  )

}

#' Normalize normality test identifiers
#'
#' @param x Test name returned by `vars::normality.test()`.
#'
#' @return A character scalar.
#' @keywords internal
normality_test_name <- function(x) {

  switch(
    x,
    JB = "jarque_bera",
    Skewness = "skewness",
    Kurtosis = "kurtosis",
    x
  )
}
