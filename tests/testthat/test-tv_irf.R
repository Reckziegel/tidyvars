make_irf_var_model <- function() {
  vars::VAR(
    vars::Canada,
    p = 2,
    type = "const"
  )
}

test_that("tv_irf() returns the IRF contract for varest objects", {
  model <- make_irf_var_model()

  result <- tv_irf(
    model,
    n.ahead = 4,
    boot = FALSE
  )

  expect_s3_class(result, "tv_irf")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "horizon",
      "impulse",
      "response",
      "estimate",
      "lower",
      "upper"
    )
  )

  expect_type(result$horizon, "integer")
  expect_type(result$impulse, "character")
  expect_type(result$response, "character")
  expect_type(result$estimate, "double")
  expect_type(result$lower, "double")
  expect_type(result$upper, "double")
})

test_that("each tv_irf() row identifies one impulse-response-horizon", {
  model <- make_irf_var_model()
  n_ahead <- 4L

  result <- tv_irf(
    model,
    n.ahead = n_ahead,
    boot = FALSE
  )

  expected_n <- model$K^2 * (n_ahead + 1L)

  expect_equal(
    nrow(result),
    expected_n
  )

  keys <- result |>
    dplyr::count(
      .data$horizon,
      .data$impulse,
      .data$response
    )

  expect_true(all(keys$n == 1L))
})

test_that("tv_irf() uses horizons from zero through n.ahead", {
  model <- make_irf_var_model()

  result <- tv_irf(
    model,
    n.ahead = 4,
    boot = FALSE
  )

  expect_identical(
    sort(unique(result$horizon)),
    0:4
  )
})

test_that("tv_irf() preserves impulse-response coefficients from vars", {
  model <- make_irf_var_model()

  expected <- vars::irf(
    model,
    impulse = "e",
    response = c("prod", "rw"),
    n.ahead = 3,
    boot = FALSE
  )

  result <- tv_irf(
    model,
    impulse = "e",
    response = c("prod", "rw"),
    n.ahead = 3,
    boot = FALSE
  )

  observed <- result |>
    dplyr::filter(
      .data$impulse == "e",
      .data$response == "prod"
    ) |>
    dplyr::arrange(.data$horizon)

  expect_equal(
    observed$estimate,
    unname(expected$irf[["e"]][, "prod"])
  )
})

test_that("tv_irf() returns missing confidence bounds when boot is false", {
  model <- make_irf_var_model()

  result <- tv_irf(
    model,
    n.ahead = 3,
    boot = FALSE
  )

  expect_true(all(is.na(result$lower)))
  expect_true(all(is.na(result$upper)))
})

test_that("tv_irf() preserves bootstrap confidence bounds from vars", {
  model <- make_irf_var_model()

  expected <- vars::irf(
    model,
    impulse = "e",
    response = "prod",
    n.ahead = 2,
    boot = TRUE,
    runs = 20,
    seed = 123
  )

  result <- tv_irf(
    model,
    impulse = "e",
    response = "prod",
    n.ahead = 2,
    boot = TRUE,
    runs = 20,
    seed = 123
  )

  observed <- result |>
    dplyr::arrange(.data$horizon)

  expect_equal(
    observed$estimate,
    unname(expected$irf[["e"]][, "prod"])
  )

  expect_equal(
    observed$lower,
    unname(expected$Lower[["e"]][, "prod"])
  )

  expect_equal(
    observed$upper,
    unname(expected$Upper[["e"]][, "prod"])
  )
})

test_that("tv_irf() respects impulse and response selections", {
  model <- make_irf_var_model()

  result <- tv_irf(
    model,
    impulse = c("e", "rw"),
    response = c("prod", "U"),
    n.ahead = 2,
    boot = FALSE
  )

  expect_setequal(
    unique(result$impulse),
    c("e", "rw")
  )

  expect_setequal(
    unique(result$response),
    c("prod", "U")
  )

  expect_equal(
    nrow(result),
    2L * 2L * 3L
  )
})

test_that("tv_irf() supports vec2var objects", {
  vecm <- urca::ca.jo(
    vars::Canada,
    type = "trace",
    ecdet = "const",
    K = 2
  )

  model <- vars::vec2var(vecm, r = 1)

  result <- tv_irf(
    model,
    n.ahead = 2,
    boot = FALSE
  )

  expect_s3_class(result, "tv_irf")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "horizon",
      "impulse",
      "response",
      "estimate",
      "lower",
      "upper"
    )
  )

  expect_identical(
    sort(unique(result$horizon)),
    0:2
  )
})

test_that("tv_irf() supports svarest objects", {
  var_model <- vars::VAR(
    vars::Canada[, c("e", "prod")],
    p = 1,
    type = "const"
  )

  a_matrix <- diag(2)
  a_matrix[2, 1] <- NA_real_

  model <- vars::SVAR(
    var_model,
    estmethod = "direct",
    Amat = a_matrix,
    lrtest = FALSE,
    method = "BFGS"
  )

  result <- tv_irf(
    model,
    impulse = "e",
    response = "prod",
    n.ahead = 2,
    boot = FALSE
  )

  expect_s3_class(result, "tv_irf")
  expect_s3_class(result, "tbl_df")

  expect_equal(
    result$horizon,
    0:2
  )

  expect_true(
    all(result$impulse == "e")
  )

  expect_true(
    all(result$response == "prod")
  )
})

test_that("tv_irf() rejects unsupported classes", {
  expect_error(
    tv_irf(mtcars),
    class = "rlang_error"
  )
})
