make_augment_model <- function(p = 2L) {
  set.seed(123)

  dates <- seq.Date(
    from = as.Date("2020-01-01"),
    by = "month",
    length.out = 24
  )

  y <- cbind(
    y1 = cumsum(stats::rnorm(24)),
    y2 = cumsum(stats::rnorm(24))
  )

  rownames(y) <- as.character(dates)

  vars::VAR(y, p = p, type = "const")

}

test_that("tv_augment() returns the augment contract for varest objects", {
  model <- make_augment_model()
  result <- tv_augment(model)

  expect_s3_class(result, "tv_augment")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "index",
      "variable",
      "observed",
      "fitted",
      "residual"
    )
  )

  expect_s3_class(result$index, "Date")
  expect_type(result$variable, "character")
  expect_type(result$observed, "double")
  expect_type(result$fitted, "double")
  expect_type(result$residual, "double")
})

test_that("tv_augment() returns one row per variable and original observation", {
  model <- make_augment_model()
  result <- tv_augment(model)

  expected_n <- nrow(model$y) * model$K

  expect_equal(nrow(result), expected_n)

  keys <- result |>
    dplyr::count(.data$index, .data$variable)

  expect_true(all(keys$n == 1L))
})

test_that("tv_augment() preserves the original observed values", {
  model <- make_augment_model()
  result <- tv_augment(model)

  target_index <- as.Date(rownames(model$y))[[1]]
  target_variable <- colnames(model$y)[[1]]

  observed <- result |>
    dplyr::filter(
      .data$index == .env$target_index,
      .data$variable == .env$target_variable
    )

  expect_equal(nrow(observed), 1L)

  expect_equal(
    observed$observed,
    unname(model$y[1, 1])
  )
})

test_that("tv_augment() leaves unavailable initial fits and residuals missing", {
  model <- make_augment_model(p = 2L)
  result <- tv_augment(model)

  fitted_values <- stats::fitted(model)
  n_initial <- nrow(model$y) - nrow(fitted_values)

  expect_equal(n_initial, model$p)

  initial_indices <- as.Date(rownames(model$y))[seq_len(n_initial)]

  initial <- result |>
    dplyr::filter(.data$index %in% .env$initial_indices)

  expect_true(all(is.na(initial$fitted)))
  expect_true(all(is.na(initial$residual)))
})

test_that("tv_augment() aligns fitted values with their original observations", {
  model <- make_augment_model(p = 2L)
  result <- tv_augment(model)

  fitted_values <- stats::fitted(model)
  residual_values <- stats::residuals(model)

  first_estimation_row <- nrow(model$y) - nrow(fitted_values) + 1L
  target_index <- as.Date(rownames(model$y))[[first_estimation_row]]
  target_variable <- colnames(model$y)[[1]]

  observed <- result |>
    dplyr::filter(
      .data$index == .env$target_index,
      .data$variable == .env$target_variable
    )

  expect_equal(nrow(observed), 1L)

  expect_equal(
    observed$observed,
    unname(model$y[first_estimation_row, 1])
  )

  expect_equal(
    observed$fitted,
    unname(fitted_values[1, 1])
  )

  expect_equal(
    observed$residual,
    unname(residual_values[1, 1])
  )
})

test_that("observed equals fitted plus residual in the estimation sample", {
  model <- make_augment_model(p = 2L)

  effective <- tv_augment(model) |>
    dplyr::filter(!is.na(.data$fitted))

  expect_equal(
    effective$observed,
    effective$fitted + effective$residual,
    tolerance = 1e-10
  )
})

test_that("tv_augment() uses integer positions when no index is available", {
  set.seed(456)

  y <- cbind(
    y1 = stats::rnorm(20),
    y2 = stats::rnorm(20)
  )

  model <- vars::VAR(y, p = 1)
  result <- tv_augment(model)

  expect_type(result$index, "integer")

  expect_equal(
    unique(result$index),
    seq_len(nrow(model$y))
  )
})

test_that("tv_augment() supports vec2var objects", {
  vecm <- urca::ca.jo(
    vars::Canada,
    type = "trace",
    ecdet = "const",
    K = 2
  )

  model <- vars::vec2var(vecm, r = 1)
  result <- tv_augment(model)

  expect_s3_class(result, "tv_augment")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "index",
      "variable",
      "observed",
      "fitted",
      "residual"
    )
  )

  expect_setequal(
    unique(result$variable),
    colnames(model$y)
  )

  effective <- result |>
    dplyr::filter(!is.na(.data$fitted))

  expect_equal(
    effective$observed,
    effective$fitted + effective$residual,
    tolerance = 1e-10
  )
})

test_that("tv_augment() rejects unsupported classes", {
  expect_error(
    tv_augment(mtcars),
    class = "rlang_error"
  )
})
