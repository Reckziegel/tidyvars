make_print_varest <- function() {
  data("Canada", package = "vars", envir = environment())

  vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )
}


test_that("tv_tidy print reports equations and terms", {
  model <- make_print_varest()
  result <- tv_tidy(model)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars coefficients>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Equations:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Terms:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("# A tibble:", output, fixed = TRUE))
  )
})


test_that("tv_glance print reports equations", {
  model <- make_print_varest()
  result <- tv_glance(model)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars equation summaries>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Equations:", output, fixed = TRUE))
  )
})


test_that("tv_augment print reports variables and observations", {
  model <- make_print_varest()
  result <- tv_augment(model)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars augmented data>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Variables:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Observations:", output, fixed = TRUE))
  )
})


test_that("tv_irf print reports its structural dimensions", {
  model <- make_print_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars IRF>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Impulses:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Responses:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Horizons: 0-4", output, fixed = TRUE))
  )
})


test_that("tv_fevd print reports its structural dimensions", {
  model <- make_print_varest()
  result <- tv_fevd(model, n.ahead = 4)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars FEVD>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Responses:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Shocks:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Horizons: 1-4", output, fixed = TRUE))
  )
})


test_that("tv_predict print reports history and forecast periods", {
  model <- make_print_varest()
  result <- tv_predict(model, n_ahead = 4)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars forecast>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Variables:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Forecast: 4", output, fixed = TRUE))
  )
})


test_that("tv_causality print reports causes and tests", {
  model <- make_print_varest()
  result <- tv_causality(model)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars causality tests>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Causes:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Tests:", output, fixed = TRUE))
  )
})


test_that("tv_normality_test print reports scopes and tests", {
  model <- make_print_varest()

  result <- tv_normality_test(
    model,
    multivariate.only = FALSE
  )

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars normality tests>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Scopes:", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Tests:", output, fixed = TRUE))
  )
})


test_that("tv_serial_test print reports tests", {
  model <- make_print_varest()
  result <- tv_serial_test(model)

  output <- capture.output(print(result))

  expect_true(
    any(grepl("<tidyvars serial tests>", output, fixed = TRUE))
  )

  expect_true(
    any(grepl("Tests:", output, fixed = TRUE))
  )
})


test_that("print methods return their input invisibly", {
  model <- make_print_varest()

  objects <- list(
    tv_tidy(model),
    tv_glance(model),
    tv_augment(model),
    tv_irf(model, n.ahead = 2, boot = FALSE),
    tv_fevd(model, n.ahead = 2),
    tv_predict(model, n_ahead = 2),
    tv_causality(model),
    tv_normality_test(model),
    tv_serial_test(model)
  )

  purrr::walk(objects, function(x) {
    printed <- NULL

    capture.output(
      printed <- print(x)
    )

    expect_identical(printed, x)
  })
})
