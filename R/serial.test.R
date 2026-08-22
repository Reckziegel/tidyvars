#' Tidy VAR serial correlation test
#'
#' Computes a multivariate serial correlation test for the residuals of a
#' supported VAR model using [vars::serial.test()] and converts the result
#' to a tidy tibble.
#'
#' Each row represents one serial correlation test for the VAR residuals
#' with a given lag specification.
#'
#' @param x A supported VAR model object. Currently supports objects of class
#'   `varest` and `vec2var`.
#' @param lags_pt Integer. Number of lags used by the Portmanteau tests.
#' @param lags_bg Integer. Number of lags used by the Breusch-Godfrey and
#'   Edgerton-Shukur tests.
#' @param type Character. Serial correlation test to compute. One of
#'   `"PT.asymptotic"`, `"PT.adjusted"`, `"BG"`, or `"ES"`.
#' @param ... Reserved for extensions. Currently must be empty.
#'
#' @return
#' A one-row tibble with the following columns:
#' \describe{
#'   \item{test}{Character. Identifier of the serial correlation test.}
#'   \item{lags}{Integer. Number of lags used by the test.}
#'   \item{statistic}{Double. Test statistic.}
#'   \item{df}{Double. Degrees of freedom for chi-squared tests.}
#'   \item{df1}{Double. Numerator degrees of freedom for the
#'   Edgerton-Shukur F test.}
#'   \item{df2}{Double. Denominator degrees of freedom for the
#'   Edgerton-Shukur F test.}
#'   \item{p_value}{Double. p-value associated with the test statistic.}
#'   \item{method}{Character. Description of the statistical test.}
#' }
#'
#' Parameter columns that do not apply to a given test are returned as `NA`.
#' The Portmanteau and Breusch-Godfrey tests use `df`. The Edgerton-Shukur
#' test uses `df1` and `df2`.
#'
#' @seealso [vars::serial.test()]
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets, p = 2)
#'
#' tv_serial_test(
#'   model,
#'   lags_pt = 8,
#'   type = "PT.adjusted"
#' )
#'
#' tv_serial_test(
#'   model,
#'   lags_bg = 2,
#'   type = "BG"
#' )
tv_serial_test <- function(
    x,
    lags_pt = 16,
    lags_bg = 5,
    type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
    ...) {
  UseMethod("tv_serial_test")
}

#' @rdname tv_serial_test
#' @export
tv_serial_test.default <- function(
    x,
    lags_pt = 16,
    lags_bg = 5,
    type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
    ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_serial_test} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_serial_test
#' @export
tv_serial_test.varest <- function(
    x,
    lags_pt = 16,
    lags_bg = 5,
    type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"),
    ...) {
  tidy_serial_test_impl(
    x,
    lags_pt = lags_pt,
    lags_bg = lags_bg,
    type = type,
    ...
  )
}

#' @rdname tv_serial_test
#' @export
tv_serial_test.vec2var <- function(x, lags_pt = 16, lags_bg = 5,
                                   type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"), ...) {

  tidy_serial_test_impl(x, lags_pt = lags_pt, lags_bg = lags_bg, type = type, ...)

}

#' Extract a tidy serial correlation test
#'
#' @param x A supported VAR model object.
#' @param lags_pt Number of lags for Portmanteau tests.
#' @param lags_bg Number of lags for BG and ES tests.
#' @param type Serial correlation test type.
#' @param ... Reserved for extensions.
#'
#' @return A `tv_serial_test` tibble.
#' @keywords internal
tidy_serial_test_impl <- function(x, lags_pt, lags_bg, type, ...) {

  rlang::check_dots_empty()

  type <- match.arg(
    type,
    c("PT.asymptotic", "PT.adjusted", "BG", "ES")
  )

  lags_pt <- abs(as.integer(lags_pt))
  lags_bg <- abs(as.integer(lags_bg))

  result <- vars::serial.test(
    x = x,
    lags.pt = lags_pt,
    lags.bg = lags_bg,
    type = type
  )

  test_result <- result$serial

  lags <- if (type %in% c("PT.asymptotic", "PT.adjusted")) {
    lags_pt
  } else {
    lags_bg
  }

  out <- tibble::tibble(
    test = serial_test_name(type),
    lags = lags,
    statistic = as.numeric(test_result$statistic),
    df = htest_parameter(test_result, "df"),
    df1 = htest_parameter(test_result, "df1"),
    df2 = htest_parameter(test_result, "df2"),
    p_value = as.numeric(test_result$p.value),
    method = test_result$method
  )

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_serial_test"
  )
}

#' Normalize serial correlation test identifiers
#'
#' @param type Test type used by [vars::serial.test()].
#'
#' @return A character scalar.
#' @keywords internal
serial_test_name <- function(type) {

  switch(
    type,
    "PT.asymptotic" = "portmanteau_asymptotic",
    "PT.adjusted" = "portmanteau_adjusted",
    "BG" = "breusch_godfrey",
    "ES" = "edgerton_shukur"
  )
}
