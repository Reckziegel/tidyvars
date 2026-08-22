
# tests/testthat/test-tv_tidy.R -------------------------------------------

test_that("tv_tidy() returns the coefficient contract for varest objects", {
  model <- vars::VAR(EuStockMarkets, p = 1)
  result <- tv_tidy(model)

  expect_s3_class(result, "tv_tidy")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "equation",
      "term",
      "estimate",
      "std_error",
      "statistic",
      "p_value"
    )
  )

  expect_type(result$equation, "character")
  expect_type(result$term, "character")
  expect_type(result$estimate, "double")
  expect_type(result$std_error, "double")
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
})

test_that("each tv_tidy() row identifies one coefficient in one equation", {
  model <- vars::VAR(EuStockMarkets, p = 1)
  result <- tv_tidy(model)
  coefficients <- stats::coef(model)

  expected_n <- sum(
    purrr::map_int(coefficients, nrow)
  )

  expect_equal(nrow(result), expected_n)

  keys <- result |>
    dplyr::count(.data$equation, .data$term)

  expect_true(all(keys$n == 1L))
})

test_that("tv_tidy() preserves coefficient values from vars", {
  model <- vars::VAR(EuStockMarkets, p = 1)
  result <- tv_tidy(model)
  coefficients <- stats::coef(model)

  equation_name <- names(coefficients)[[1]]
  term_name <- rownames(coefficients[[equation_name]])[[1]]

  expected <- coefficients[[equation_name]][term_name, ]

  observed <- result |>
    dplyr::filter(
      .data$equation == .env$equation_name,
      .data$term == .env$term_name
    )

  expect_equal(nrow(observed), 1L)

  expect_equal(
    observed$estimate,
    unname(expected[["Estimate"]])
  )

  expect_equal(
    observed$std_error,
    unname(expected[["Std. Error"]])
  )

  expect_equal(
    observed$statistic,
    unname(expected[["t value"]])
  )

  expect_equal(
    observed$p_value,
    unname(expected[["Pr(>|t|)"]])
  )
})

test_that("tv_tidy() preserves character equation and term columns", {
  model <- vars::VAR(EuStockMarkets, p = 1)
  result <- tv_tidy(model)

  expect_false(is.factor(result$equation))
  expect_false(is.factor(result$term))
})

test_that("tv_tidy() handles different coefficient counts by equation", {
  model <- vars::VAR(EuStockMarkets, p = 1)

  n_equations <- model$K
  n_regressors <- ncol(model$datamat) - model$K

  restrictions <- matrix(
    1,
    nrow = n_equations,
    ncol = n_regressors
  )

  restrictions[1, 1] <- 0
  restrictions[2, 1:2] <- 0

  restricted <- vars::restrict(
    model,
    method = "manual",
    resmat = restrictions
  )

  result <- tv_tidy(restricted)
  coefficients <- stats::coef(restricted)

  expected <- tibble::tibble(
    equation = names(coefficients),
    n_expected = unname(purrr::map_int(coefficients, nrow))
  )

  observed <- result |>
    dplyr::count(
      .data$equation,
      name = "n_observed"
    )

  counts <- expected |>
    dplyr::left_join(
      observed,
      by = "equation"
    )

  expect_gt(
    dplyr::n_distinct(counts$n_expected),
    1L
  )

  expect_equal(
    counts$n_observed,
    counts$n_expected
  )
})

test_that("tv_tidy() rejects unsupported classes", {
  expect_error(
    tv_tidy(mtcars),
    class = "rlang_error"
  )
})

test_that("tv_tidy() does not claim inferential support for vec2var", {
  vecm <- urca::ca.jo(
    vars::Canada,
    type = "trace",
    ecdet = "const",
    K = 2
  )

  model <- vars::vec2var(vecm, r = 1)

  expect_error(
    tv_tidy(model),
    "does not currently support"
  )
})
