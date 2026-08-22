make_fevd_var_model <- function() {
  vars::VAR(
    vars::Canada,
    p = 2,
    type = "const"
  )
}

test_that("tv_fevd() returns the FEVD contract for varest objects", {
  model <- make_fevd_var_model()

  result <- tv_fevd(
    model,
    n.ahead = 4
  )

  expect_s3_class(result, "tv_fevd")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "horizon",
      "response",
      "shock",
      "contribution"
    )
  )

  expect_type(result$horizon, "integer")
  expect_type(result$response, "character")
  expect_type(result$shock, "character")
  expect_type(result$contribution, "double")
})

test_that("each tv_fevd() row identifies one response-shock-horizon", {
  model <- make_fevd_var_model()
  n_ahead <- 4L

  result <- tv_fevd(
    model,
    n.ahead = n_ahead
  )

  expected_n <- model$K^2 * n_ahead

  expect_equal(
    nrow(result),
    expected_n
  )

  keys <- result |>
    dplyr::count(
      .data$horizon,
      .data$response,
      .data$shock
    )

  expect_true(all(keys$n == 1L))
})

test_that("tv_fevd() uses horizons from one through n.ahead", {
  model <- make_fevd_var_model()

  result <- tv_fevd(
    model,
    n.ahead = 4
  )

  expect_identical(
    sort(unique(result$horizon)),
    1:4
  )
})

test_that("tv_fevd() preserves contributions from vars", {
  model <- make_fevd_var_model()
  n_ahead <- 4L

  expected <- vars::fevd(
    model,
    n.ahead = n_ahead
  )

  result <- tv_fevd(
    model,
    n.ahead = n_ahead
  )

  response_name <- names(expected)[[1]]
  shock_name <- colnames(expected[[response_name]])[[1]]

  observed <- result |>
    dplyr::filter(
      .data$response == .env$response_name,
      .data$shock == .env$shock_name
    ) |>
    dplyr::arrange(.data$horizon)

  expect_equal(
    nrow(observed),
    n_ahead
  )

  expect_equal(
    observed$contribution,
    unname(expected[[response_name]][, shock_name])
  )
})

test_that("tv_fevd() preserves response and shock identities", {
  model <- make_fevd_var_model()

  result <- tv_fevd(
    model,
    n.ahead = 3
  )

  variable_names <- colnames(model$y)

  expect_setequal(
    unique(result$response),
    variable_names
  )

  expect_setequal(
    unique(result$shock),
    variable_names
  )
})

test_that("tv_fevd() contributions are finite and non-negative", {
  model <- make_fevd_var_model()

  result <- tv_fevd(
    model,
    n.ahead = 5
  )

  expect_true(
    all(is.finite(result$contribution))
  )

  expect_true(
    all(result$contribution >= 0)
  )
})

test_that("FEVD contributions sum to one for each response and horizon", {
  model <- make_fevd_var_model()

  totals <- tv_fevd(
    model,
    n.ahead = 5
  ) |>
    dplyr::summarise(
      total = sum(.data$contribution),
      .by = c("horizon", "response")
    )

  expect_equal(
    totals$total,
    rep(1, nrow(totals)),
    tolerance = 1e-10
  )
})

test_that("tv_fevd() supports vec2var objects", {
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

  result <- tv_fevd(
    model,
    n.ahead = 3
  )

  expect_s3_class(result, "tv_fevd")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "horizon",
      "response",
      "shock",
      "contribution"
    )
  )

  expect_identical(
    sort(unique(result$horizon)),
    1:3
  )

  totals <- result |>
    dplyr::summarise(
      total = sum(.data$contribution),
      .by = c("horizon", "response")
    )

  expect_equal(
    totals$total,
    rep(1, nrow(totals)),
    tolerance = 1e-10
  )
})

test_that("tv_fevd() rejects unsupported classes", {
  expect_error(
    tv_fevd(mtcars),
    class = "rlang_error"
  )
})
