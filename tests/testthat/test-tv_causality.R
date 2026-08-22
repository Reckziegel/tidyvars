make_causality_model <- function() {
  vars::VAR(
    vars::Canada[, c("e", "prod")],
    p = 1,
    type = "const"
  )
}

test_that("tv_causality() returns the causality contract", {
  model <- make_causality_model()
  result <- tv_causality(model)

  expect_s3_class(result, "tv_causality")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "cause",
      "test",
      "statistic",
      "df",
      "df1",
      "df2",
      "boot_runs",
      "p_value",
      "method"
    )
  )

  expect_type(result$cause, "character")
  expect_type(result$test, "character")
  expect_type(result$statistic, "double")
  expect_type(result$df, "double")
  expect_type(result$df1, "double")
  expect_type(result$df2, "double")
  expect_type(result$boot_runs, "double")
  expect_type(result$p_value, "double")
  expect_type(result$method, "character")
})

test_that("each tv_causality() row identifies one cause and test", {
  model <- make_causality_model()
  result <- tv_causality(model)

  causes <- names(stats::coef(model))

  expect_equal(
    nrow(result),
    length(causes) * 2L
  )

  keys <- result |>
    dplyr::count(
      .data$cause,
      .data$test
    )

  expect_true(all(keys$n == 1L))

  expect_setequal(
    unique(result$cause),
    causes
  )

  expect_setequal(
    unique(result$test),
    c("granger", "instantaneous")
  )
})

test_that("tv_causality() preserves Granger results from vars", {
  model <- make_causality_model()
  cause_name <- names(stats::coef(model))[[1]]

  expected <- vars::causality(
    model,
    cause = cause_name
  )$Granger

  observed <- tv_causality(model) |>
    dplyr::filter(
      .data$cause == .env$cause_name,
      .data$test == "granger"
    )

  expect_equal(nrow(observed), 1L)

  expect_equal(
    observed$statistic,
    as.numeric(expected$statistic)
  )

  expect_equal(
    observed$df1,
    as.numeric(expected$parameter[["df1"]])
  )

  expect_equal(
    observed$df2,
    as.numeric(expected$parameter[["df2"]])
  )

  expect_true(is.na(observed$df))
  expect_true(is.na(observed$boot_runs))

  expect_equal(
    observed$p_value,
    as.numeric(expected$p.value)
  )

  expect_equal(
    observed$method,
    expected$method
  )
})

test_that("tv_causality() preserves instantaneous causality results", {
  model <- make_causality_model()
  cause_name <- names(stats::coef(model))[[1]]

  expected <- vars::causality(
    model,
    cause = cause_name
  )$Instant

  observed <- tv_causality(model) |>
    dplyr::filter(
      .data$cause == .env$cause_name,
      .data$test == "instantaneous"
    )

  expect_equal(nrow(observed), 1L)

  expect_equal(
    observed$statistic,
    as.numeric(expected$statistic)
  )

  expect_equal(
    observed$df,
    as.numeric(expected$parameter[["df"]])
  )

  expect_true(is.na(observed$df1))
  expect_true(is.na(observed$df2))
  expect_true(is.na(observed$boot_runs))

  expect_equal(
    observed$p_value,
    as.numeric(expected$p.value)
  )

  expect_equal(
    observed$method,
    expected$method
  )
})

test_that("tv_causality() forwards bootstrap arguments to vars", {
  model <- make_causality_model()

  set.seed(123)

  result <- tv_causality(
    model,
    boot = TRUE,
    boot.runs = 5
  )

  granger <- result |>
    dplyr::filter(.data$test == "granger")

  expect_true(
    all(granger$boot_runs == 5)
  )

  expect_true(
    all(is.na(granger$df))
  )

  expect_true(
    all(is.na(granger$df1))
  )

  expect_true(
    all(is.na(granger$df2))
  )

  expect_true(
    all(is.finite(granger$statistic))
  )

  expect_true(
    all(granger$p_value >= 0 & granger$p_value <= 1)
  )
})

test_that("tv_causality() keeps cause and test semantically neutral", {
  model <- make_causality_model()
  result <- tv_causality(model)

  expect_false(is.factor(result$cause))
  expect_false(is.factor(result$test))
})

test_that("tv_causality() returns valid p-values", {
  model <- make_causality_model()
  result <- tv_causality(model)

  expect_true(
    all(result$p_value >= 0 & result$p_value <= 1)
  )
})

test_that("tv_causality() rejects unsupported classes", {
  expect_error(
    tv_causality(mtcars),
    class = "rlang_error"
  )
})
