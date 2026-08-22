make_serial_model <- function() {
  vars::VAR(
    vars::Canada[, c("e", "prod")],
    p = 1,
    type = "const"
  )
}

test_that("tv_serial_test() returns the serial test contract", {
  model <- make_serial_model()
  result <- tv_serial_test(model)

  expect_s3_class(result, "tv_serial_test")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "test",
      "lags",
      "statistic",
      "df",
      "df1",
      "df2",
      "p_value",
      "method"
    )
  )

  expect_type(result$test, "character")
  expect_type(result$lags, "integer")
  expect_type(result$statistic, "double")
  expect_type(result$df, "double")
  expect_type(result$df1, "double")
  expect_type(result$df2, "double")
  expect_type(result$p_value, "double")
  expect_type(result$method, "character")
})

test_that("tv_serial_test() returns exactly one test per call", {
  model <- make_serial_model()
  result <- tv_serial_test(model)

  expect_equal(
    nrow(result),
    1L
  )
})

test_that("tv_serial_test() identifies all supported test types", {
  model <- make_serial_model()

  types <- c(
    "PT.asymptotic",
    "PT.adjusted",
    "BG",
    "ES"
  )

  expected <- c(
    "portmanteau_asymptotic",
    "portmanteau_adjusted",
    "breusch_godfrey",
    "edgerton_shukur"
  )

  observed <- purrr::map_chr(
    types,
    \(type) {
      tv_serial_test(
        model,
        lags_pt = 4,
        lags_bg = 2,
        type = type
      )$test
    }
  )

  expect_identical(
    observed,
    expected
  )
})

test_that("Portmanteau test preserves results from vars", {
  model <- make_serial_model()

  expected <- vars::serial.test(
    model,
    lags.pt = 4,
    type = "PT.adjusted"
  )$serial

  observed <- tv_serial_test(
    model,
    lags_pt = 4,
    type = "PT.adjusted"
  )

  expect_equal(
    observed$test,
    "portmanteau_adjusted"
  )

  expect_equal(
    observed$lags,
    4L
  )

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

  expect_equal(
    observed$p_value,
    as.numeric(expected$p.value)
  )

  expect_equal(
    observed$method,
    expected$method
  )
})

test_that("Breusch-Godfrey test preserves results from vars", {
  model <- make_serial_model()

  expected <- vars::serial.test(
    model,
    lags.bg = 2,
    type = "BG"
  )$serial

  observed <- tv_serial_test(
    model,
    lags_bg = 2,
    type = "BG"
  )

  expect_equal(
    observed$test,
    "breusch_godfrey"
  )

  expect_equal(
    observed$lags,
    2L
  )

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

  expect_equal(
    observed$p_value,
    as.numeric(expected$p.value)
  )

  expect_equal(
    observed$method,
    expected$method
  )
})

test_that("Edgerton-Shukur test preserves both degrees of freedom", {
  model <- make_serial_model()

  expected <- vars::serial.test(
    model,
    lags.bg = 2,
    type = "ES"
  )$serial

  observed <- tv_serial_test(
    model,
    lags_bg = 2,
    type = "ES"
  )

  expect_equal(
    observed$test,
    "edgerton_shukur"
  )

  expect_equal(
    observed$lags,
    2L
  )

  expect_equal(
    observed$statistic,
    as.numeric(expected$statistic)
  )

  expect_true(is.na(observed$df))

  expect_equal(
    observed$df1,
    as.numeric(expected$parameter[["df1"]])
  )

  expect_equal(
    observed$df2,
    as.numeric(expected$parameter[["df2"]])
  )

  expect_equal(
    observed$p_value,
    as.numeric(expected$p.value)
  )

  expect_equal(
    observed$method,
    expected$method
  )
})

test_that("tv_serial_test() uses the lag argument relevant to the test", {
  model <- make_serial_model()

  portmanteau <- tv_serial_test(
    model,
    lags_pt = 7,
    lags_bg = 2,
    type = "PT.asymptotic"
  )

  breusch_godfrey <- tv_serial_test(
    model,
    lags_pt = 7,
    lags_bg = 2,
    type = "BG"
  )

  expect_equal(
    portmanteau$lags,
    7L
  )

  expect_equal(
    breusch_godfrey$lags,
    2L
  )
})

test_that("tv_serial_test() returns valid p-values", {
  model <- make_serial_model()

  types <- c(
    "PT.asymptotic",
    "PT.adjusted",
    "BG",
    "ES"
  )

  p_values <- purrr::map_dbl(
    types,
    \(type) {
      tv_serial_test(
        model,
        lags_pt = 4,
        lags_bg = 2,
        type = type
      )$p_value
    }
  )

  expect_true(
    all(p_values >= 0 & p_values <= 1)
  )
})

test_that("tv_serial_test() keeps test identifiers as character", {
  model <- make_serial_model()

  result <- tv_serial_test(
    model,
    type = "PT.adjusted"
  )

  expect_false(
    is.factor(result$test)
  )
})

test_that("tv_serial_test() supports vec2var objects", {
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

  expected <- vars::serial.test(
    model,
    lags.bg = 2,
    type = "BG"
  )$serial

  result <- tv_serial_test(
    model,
    lags_bg = 2,
    type = "BG"
  )

  expect_s3_class(
    result,
    "tv_serial_test"
  )

  expect_s3_class(
    result,
    "tbl_df"
  )

  expect_equal(
    result$statistic,
    as.numeric(expected$statistic)
  )

  expect_equal(
    result$df,
    as.numeric(expected$parameter[["df"]])
  )

  expect_equal(
    result$p_value,
    as.numeric(expected$p.value)
  )
})

test_that("tv_serial_test() rejects additional arguments", {
  model <- make_serial_model()

  expect_error(
    tv_serial_test(
      model,
      unused_argument = TRUE
    )
  )
})

test_that("tv_serial_test() rejects unsupported classes", {
  expect_error(
    tv_serial_test(mtcars),
    class = "rlang_error"
  )
})
