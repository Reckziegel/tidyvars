make_glance_varest <- function() {
  data("Canada", package = "vars", envir = environment())

  vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )
}


test_that("tv_glance() returns the documented schema and classes", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  expect_s3_class(result, "tv_glance")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "equation",
      "r_squared",
      "adj_r_squared",
      "sigma",
      "statistic",
      "p_value",
      "df",
      "log_lik",
      "aic",
      "bic",
      "deviance",
      "df_residual",
      "n_obs"
    )
  )
})


test_that("tv_glance() returns one row per VAR equation", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  expect_equal(
    nrow(result),
    length(model$varresult)
  )

  expect_identical(
    result$equation,
    names(model$varresult)
  )

  expect_equal(
    dplyr::n_distinct(result$equation),
    nrow(result)
  )
})


test_that("tv_glance() returns stable public column types", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  expect_type(result$equation, "character")
  expect_type(result$r_squared, "double")
  expect_type(result$adj_r_squared, "double")
  expect_type(result$sigma, "double")
  expect_type(result$statistic, "double")
  expect_type(result$p_value, "double")
  expect_type(result$df, "double")
  expect_type(result$log_lik, "double")
  expect_type(result$aic, "double")
  expect_type(result$bic, "double")
  expect_type(result$deviance, "double")

  expect_true(is.numeric(result$df_residual))
  expect_true(is.numeric(result$n_obs))
})


test_that("tv_glance() preserves broom glance results for each equation", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  purrr::walk(names(model$varresult), function(equation) {
    expected <- broom::glance(model$varresult[[equation]])

    actual <- result |>
      dplyr::filter(.data$equation == .env$equation)

    expect_equal(nrow(actual), 1L)

    expect_equal(actual$r_squared, expected$r.squared)
    expect_equal(actual$adj_r_squared, expected$adj.r.squared)
    expect_equal(actual$sigma, expected$sigma)
    expect_equal(actual$statistic, expected$statistic)
    expect_equal(actual$p_value, expected$p.value)
    expect_equal(actual$df, expected$df)
    expect_equal(actual$log_lik, expected$logLik)
    expect_equal(actual$aic, expected$AIC)
    expect_equal(actual$bic, expected$BIC)
    expect_equal(actual$deviance, expected$deviance)
    expect_equal(actual$df_residual, expected$df.residual)
    expect_equal(actual$n_obs, expected$nobs)
  })
})


test_that("equation identifies rows uniquely", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  duplicates <- result |>
    dplyr::count(.data$equation, name = "n") |>
    dplyr::filter(.data$n > 1L)

  expect_equal(nrow(duplicates), 0L)
})


test_that("tv_glance() preserves equation order", {
  model <- make_glance_varest()
  result <- tv_glance(model)

  expect_identical(
    result$equation,
    names(model$varresult)
  )
})


test_that("tv_glance() rejects unsupported classes", {
  expect_error(
    tv_glance(stats::lm(mpg ~ wt, data = mtcars)),
    regexp = "No .*tv_glance\\(\\).* method"
  )

  expect_error(
    tv_glance(matrix(1:10, ncol = 2)),
    regexp = "No .*tv_glance\\(\\).* method"
  )
})
