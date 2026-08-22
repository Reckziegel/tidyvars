make_normality_model <- function() {
  vars::VAR(
    vars::Canada[, c("e", "prod")],
    p = 1,
    type = "const"
  )
}

test_that("tv_normality_test() returns the normality contract", {
  model <- make_normality_model()
  result <- tv_normality_test(model)

  expect_s3_class(result, "tv_normality_test")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "scope",
      "variable",
      "test",
      "statistic",
      "df",
      "p_value",
      "method"
    )
  )

  expect_type(result$scope, "character")
  expect_type(result$variable, "character")
  expect_type(result$test, "character")
  expect_type(result$statistic, "double")
  expect_type(result$df, "double")
  expect_type(result$p_value, "double")
  expect_type(result$method, "character")
})

test_that("default tv_normality_test() returns multivariate tests only", {
  model <- make_normality_model()
  result <- tv_normality_test(model)

  expect_equal(
    nrow(result),
    3L
  )

  expect_true(
    all(result$scope == "multivariate")
  )

  expect_true(
    all(is.na(result$variable))
  )

  expect_setequal(
    result$test,
    c(
      "jarque_bera",
      "skewness",
      "kurtosis"
    )
  )
})

test_that("each multivariate normality test is uniquely identified", {
  model <- make_normality_model()

  result <- tv_normality_test(model)

  keys <- result |>
    dplyr::count(
      .data$scope,
      .data$variable,
      .data$test
    )

  expect_true(
    all(keys$n == 1L)
  )
})

test_that("tv_normality_test() preserves multivariate results from vars", {
  model <- make_normality_model()

  expected <- vars::normality.test(model)
  result <- tv_normality_test(model)

  expected_names <- c(
    JB = "jarque_bera",
    Skewness = "skewness",
    Kurtosis = "kurtosis"
  )

  purrr::iwalk(
    expected$jb.mul,
    \(expected_test, test_name) {
      tidy_name <- unname(expected_names[[test_name]])

      observed <- result |>
        dplyr::filter(
          .data$scope == "multivariate",
          .data$test == .env$tidy_name
        )

      expect_equal(
        nrow(observed),
        1L
      )

      expect_equal(
        observed$statistic,
        as.numeric(expected_test$statistic)
      )

      expect_equal(
        observed$df,
        as.numeric(expected_test$parameter[["df"]])
      )

      expect_equal(
        observed$p_value,
        as.numeric(expected_test$p.value)
      )

      expect_equal(
        observed$method,
        expected_test$method
      )
    }
  )
})

test_that("multivariate.only = FALSE includes univariate tests", {
  model <- make_normality_model()

  result <- tv_normality_test(
    model,
    multivariate.only = FALSE
  )

  expected_n <- 3L + model$K

  expect_equal(
    nrow(result),
    expected_n
  )

  multivariate <- result |>
    dplyr::filter(
      .data$scope == "multivariate"
    )

  univariate <- result |>
    dplyr::filter(
      .data$scope == "univariate"
    )

  expect_equal(
    nrow(multivariate),
    3L
  )

  expect_equal(
    nrow(univariate),
    model$K
  )

  expect_setequal(
    univariate$variable,
    colnames(model$y)
  )

  expect_true(
    all(univariate$test == "jarque_bera")
  )
})

test_that("tv_normality_test() preserves univariate results from vars", {
  model <- make_normality_model()

  expected <- vars::normality.test(
    model,
    multivariate.only = FALSE
  )

  result <- tv_normality_test(
    model,
    multivariate.only = FALSE
  )

  variable_name <- colnames(model$y)[[1]]
  expected_test <- expected$jb.uni[[variable_name]]

  observed <- result |>
    dplyr::filter(
      .data$scope == "univariate",
      .data$variable == .env$variable_name,
      .data$test == "jarque_bera"
    )

  expect_equal(
    nrow(observed),
    1L
  )

  expect_equal(
    observed$statistic,
    as.numeric(expected_test$statistic)
  )

  expect_equal(
    observed$df,
    as.numeric(expected_test$parameter[["df"]])
  )

  expect_equal(
    observed$p_value,
    as.numeric(expected_test$p.value)
  )

  expect_equal(
    observed$method,
    expected_test$method
  )
})

test_that("univariate Jarque-Bera tests use two degrees of freedom", {
  model <- make_normality_model()

  univariate <- tv_normality_test(
    model,
    multivariate.only = FALSE
  ) |>
    dplyr::filter(
      .data$scope == "univariate"
    )

  expect_equal(
    univariate$df,
    rep(2, model$K)
  )
})

test_that("multivariate degrees of freedom are preserved", {
  model <- make_normality_model()

  result <- tv_normality_test(model)

  jarque_bera <- result |>
    dplyr::filter(
      .data$test == "jarque_bera"
    )

  skewness <- result |>
    dplyr::filter(
      .data$test == "skewness"
    )

  kurtosis <- result |>
    dplyr::filter(
      .data$test == "kurtosis"
    )

  expect_equal(
    jarque_bera$df,
    2 * model$K
  )

  expect_equal(
    skewness$df,
    model$K
  )

  expect_equal(
    kurtosis$df,
    model$K
  )
})

test_that("tv_normality_test() returns valid p-values", {
  model <- make_normality_model()

  result <- tv_normality_test(
    model,
    multivariate.only = FALSE
  )

  expect_true(
    all(result$p_value >= 0 & result$p_value <= 1)
  )
})

test_that("normality dimensions remain semantically neutral", {
  model <- make_normality_model()

  result <- tv_normality_test(
    model,
    multivariate.only = FALSE
  )

  expect_false(
    is.factor(result$scope)
  )

  expect_false(
    is.factor(result$variable)
  )

  expect_false(
    is.factor(result$test)
  )
})

test_that("tv_normality_test() supports vec2var objects", {
  vecm <- urca::ca.jo(
    vars::Canada,
    type = "trace",
    ecdet = "const",
    K = 2
  )

  model <- vars::vec2var(
    vecm,
    r = 1
  )

  result <- tv_normality_test(model)

  expect_s3_class(
    result,
    "tv_normality_test"
  )

  expect_s3_class(
    result,
    "tbl_df"
  )

  expect_named(
    result,
    c(
      "scope",
      "variable",
      "test",
      "statistic",
      "df",
      "p_value",
      "method"
    )
  )

  expect_equal(
    nrow(result),
    3L
  )

  expect_true(
    all(result$scope == "multivariate")
  )
})

test_that("tv_normality_test() rejects unsupported classes", {
  expect_error(
    tv_normality_test(mtcars),
    class = "rlang_error"
  )
})
