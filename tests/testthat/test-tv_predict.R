make_predict_varest <- function() {
  data("Canada", package = "vars", envir = environment())

  vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )
}

make_indexed_predict_varest <- function(index = NULL, as_data_frame = FALSE) {
  n <- if (is.null(index)) 30L else length(index)
  position <- seq_len(n)

  y <- cbind(
    x = sin(position / 2.3) + 0.03 * position + cos(position / 7),
    y = cos(position / 3.1) - 0.02 * position + sin(position / 5)
  )

  if (!is.null(index)) {
    rownames(y) <- as.character(index)
  }

  if (as_data_frame) {
    y <- as.data.frame(y)
  }

  vars::VAR(y, p = 2, type = "const")
}


make_predict_varest <- function() {
  data("Canada", package = "vars", envir = environment())

  vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )
}

make_indexed_predict_varest <- function(index = NULL, as_data_frame = FALSE) {
  n <- if (is.null(index)) 30L else length(index)
  position <- seq_len(n)

  y <- cbind(
    x = sin(position / 2.3) + 0.03 * position + cos(position / 7),
    y = cos(position / 3.1) - 0.02 * position + sin(position / 5)
  )

  if (!is.null(index)) {
    rownames(y) <- as.character(index)
  }

  if (as_data_frame) {
    y <- as.data.frame(y)
  }

  vars::VAR(y, p = 2, type = "const")
}


test_that("tv_predict() returns the documented schema and classes", {
  model <- make_predict_varest()
  result <- tv_predict(model, n_ahead = 4)

  expect_s3_class(result, "tv_predict")
  expect_s3_class(result, "tbl_df")

  expect_named(
    result,
    c(
      "index",
      "variable",
      "type",
      "level",
      "observed",
      "estimate",
      "lower",
      "upper"
    )
  )

  expect_type(result$index, "double")
  expect_type(result$variable, "character")
  expect_type(result$type, "character")
  expect_type(result$level, "double")
  expect_type(result$observed, "double")
  expect_type(result$estimate, "double")
  expect_type(result$lower, "double")
  expect_type(result$upper, "double")

  expect_setequal(
    unique(result$type),
    c("history", "forecast")
  )
})


test_that("tv_predict() uses 0.95 as the default confidence level", {
  model <- make_predict_varest()

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  forecast <- result |>
    dplyr::filter(.data$type == "forecast")

  expect_identical(
    unique(forecast$level),
    0.95
  )
})


test_that("tv_predict() preserves the complete observed history", {
  model <- make_predict_varest()

  raw <- stats::predict(
    model,
    n.ahead = 4
  )

  result <- tv_predict(
    model,
    n_ahead = 4
  )

  n_variables <- ncol(raw$endog)

  expect_equal(
    sum(result$type == "history"),
    nrow(raw$endog) * n_variables
  )

  variable <- colnames(raw$endog)[[1]]

  history <- result |>
    dplyr::filter(
      .data$type == "history",
      .data$variable == .env$variable
    )

  expect_equal(
    history$observed,
    as.double(raw$endog[, variable])
  )
})


test_that("tv_predict() preserves vars forecasts exactly", {
  model <- make_predict_varest()
  levels <- c(0.50, 0.80, 0.95)

  purrr::walk(levels, function(level) {
    raw <- stats::predict(
      model,
      n.ahead = 5,
      ci = level
    )

    result <- tv_predict(
      model,
      n_ahead = 5,
      level = level
    )

    purrr::walk(names(raw$fcst), function(variable) {
      forecast <- result |>
        dplyr::filter(
          .data$type == "forecast",
          .data$variable == .env$variable
        )

      expect_equal(
        forecast$estimate,
        as.double(raw$fcst[[variable]][, "fcst"])
      )

      expect_equal(
        forecast$lower,
        as.double(raw$fcst[[variable]][, "lower"])
      )

      expect_equal(
        forecast$upper,
        as.double(raw$fcst[[variable]][, "upper"])
      )

      expect_true(all(forecast$level == level))
    })
  })
})


test_that("history and forecast rows obey their missing-value contracts", {
  model <- make_predict_varest()

  result <- tv_predict(
    model,
    n_ahead = 4,
    level = 0.90
  )

  history <- result |>
    dplyr::filter(.data$type == "history")

  forecast <- result |>
    dplyr::filter(.data$type == "forecast")

  expect_false(anyNA(history$observed))
  expect_true(all(is.na(history$level)))
  expect_true(all(is.na(history$estimate)))
  expect_true(all(is.na(history$lower)))
  expect_true(all(is.na(history$upper)))

  expect_true(all(is.na(forecast$observed)))
  expect_true(all(forecast$level == 0.90))
  expect_false(anyNA(forecast$estimate))
  expect_false(anyNA(forecast$lower))
  expect_false(anyNA(forecast$upper))
})


test_that("forecast row count follows horizon, variables, and levels", {
  model <- make_predict_varest()

  raw <- stats::predict(
    model,
    n.ahead = 1
  )

  n_variables <- ncol(raw$endog)
  levels <- c(0.50, 0.75, 0.90)

  purrr::walk(c(1L, 3L, 7L), function(n_ahead) {
    result <- tv_predict(
      model,
      n_ahead = n_ahead,
      level = levels
    )

    expect_equal(
      sum(result$type == "forecast"),
      n_ahead * n_variables * length(levels)
    )
  })
})


test_that("all endogenous variables are preserved", {
  model <- make_predict_varest()

  raw <- stats::predict(
    model,
    n.ahead = 3
  )

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  expect_identical(
    unique(result$variable),
    colnames(raw$endog)
  )
})


test_that("ts indices preserve their original sampling times", {
  model <- make_predict_varest()

  raw <- stats::predict(
    model,
    n.ahead = 4
  )

  result <- tv_predict(
    model,
    n_ahead = 4
  )

  variable <- names(raw$fcst)[[1]]

  history <- result |>
    dplyr::filter(
      .data$type == "history",
      .data$variable == .env$variable
    )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == .env$variable
    )

  expected_history <- as.numeric(stats::time(raw$endog))

  expected_forecast <- utils::tail(expected_history, 1L) +
    stats::deltat(raw$endog) * seq_len(4)

  expect_equal(
    history$index,
    expected_history
  )

  expect_equal(
    forecast$index,
    expected_forecast
  )

  expect_equal(
    forecast$index[[1]],
    utils::tail(history$index, 1L) +
      stats::deltat(raw$endog)
  )
})


test_that("regular monthly Date indices are extended correctly", {
  month_starts <- seq.Date(
    as.Date("2020-01-01"),
    by = "month",
    length.out = 24
  )

  index <- lubridate::ceiling_date(
    month_starts,
    unit = "month"
  ) - lubridate::days(1)

  model <- make_indexed_predict_varest(
    index,
    as_data_frame = TRUE
  )

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  history <- result |>
    dplyr::filter(
      .data$type == "history",
      .data$variable == "x"
    )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == "x"
    )

  expect_s3_class(result$index, "Date")
  expect_identical(history$index, index)

  expect_identical(
    forecast$index,
    as.Date(c(
      "2022-01-31",
      "2022-02-28",
      "2022-03-31"
    ))
  )
})


test_that("regular quarterly Date indices are extended correctly", {
  quarter_starts <- seq.Date(
    as.Date("2018-03-01"),
    by = "3 months",
    length.out = 20
  )

  index <- lubridate::ceiling_date(
    quarter_starts,
    unit = "month"
  ) - lubridate::days(1)

  model <- make_indexed_predict_varest(index)

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == "x"
    )

  expect_identical(
    forecast$index,
    as.Date(c(
      "2023-03-31",
      "2023-06-30",
      "2023-09-30"
    ))
  )
})


test_that("regular yearly Date indices are extended correctly", {
  index <- as.Date(
    paste0(2000:2019, "-12-31")
  )

  model <- make_indexed_predict_varest(index)

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == "x"
    )

  expect_identical(
    forecast$index,
    as.Date(c(
      "2020-12-31",
      "2021-12-31",
      "2022-12-31"
    ))
  )
})


test_that("regular numeric row names are preserved and extended", {
  index <- seq(
    from = 10,
    by = 0.5,
    length.out = 30
  )

  model <- make_indexed_predict_varest(index)

  result <- tv_predict(
    model,
    n_ahead = 4
  )

  history <- result |>
    dplyr::filter(
      .data$type == "history",
      .data$variable == "x"
    )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == "x"
    )

  expect_equal(
    history$index,
    index
  )

  expect_equal(
    forecast$index,
    utils::tail(index, 1L) +
      0.5 * seq_len(4)
  )
})


test_that("models without an explicit index use observation positions", {
  model <- make_indexed_predict_varest()

  result <- tv_predict(
    model,
    n_ahead = 3
  )

  history <- result |>
    dplyr::filter(
      .data$type == "history",
      .data$variable == "x"
    )

  forecast <- result |>
    dplyr::filter(
      .data$type == "forecast",
      .data$variable == "x"
    )

  expect_equal(
    history$index,
    seq_len(nrow(model$y))
  )

  expect_equal(
    forecast$index,
    nrow(model$y) + seq_len(3)
  )
})


test_that("rows obey the public forecast key", {
  model <- make_predict_varest()

  result <- tv_predict(
    model,
    n_ahead = 6,
    level = c(0.50, 0.75, 0.90)
  )

  duplicates <- result |>
    dplyr::count(
      .data$index,
      .data$variable,
      .data$type,
      .data$level,
      name = "n"
    ) |>
    dplyr::filter(.data$n > 1L)

  expect_equal(
    nrow(duplicates),
    0L
  )
})


test_that("tv_predict() requires n_ahead", {
  model <- make_predict_varest()

  expect_error(
    tv_predict(model),
    "`n_ahead` is required"
  )
})


test_that("n_ahead must be a positive whole number", {
  model <- make_predict_varest()

  invalid <- list(
    0,
    -1,
    1.5,
    NA_real_,
    Inf,
    "3"
  )

  purrr::walk(invalid, function(n_ahead) {
    expect_error(
      tv_predict(
        model,
        n_ahead = n_ahead
      ),
      "`n_ahead` must be a positive whole number"
    )
  })
})


test_that("scalar and multiple levels return the same schema", {
  model <- make_predict_varest()

  scalar <- tv_predict(
    model,
    n_ahead = 2,
    level = 0.90
  )

  multiple <- tv_predict(
    model,
    n_ahead = 2,
    level = c(0.50, 0.75, 0.90)
  )

  expected_names <- c(
    "index",
    "variable",
    "type",
    "level",
    "observed",
    "estimate",
    "lower",
    "upper"
  )

  expect_identical(
    names(scalar),
    expected_names
  )

  expect_identical(
    names(multiple),
    expected_names
  )

  expect_identical(
    names(scalar),
    names(multiple)
  )
})


test_that("historical rows are not duplicated across levels", {
  model <- make_predict_varest()

  scalar <- tv_predict(
    model,
    n_ahead = 2,
    level = 0.90
  )

  multiple <- tv_predict(
    model,
    n_ahead = 2,
    level = c(0.50, 0.75, 0.90)
  )

  scalar_history <- scalar |>
    dplyr::filter(.data$type == "history")

  multiple_history <- multiple |>
    dplyr::filter(.data$type == "history")

  expect_equal(
    multiple_history,
    scalar_history
  )

  expect_true(
    all(is.na(multiple_history$level))
  )
})


test_that("forecast rows are repeated once per confidence level", {
  model <- make_predict_varest()
  levels <- c(0.50, 0.75, 0.90)

  prediction <- tv_predict(
    model,
    n_ahead = 2,
    level = levels
  )

  forecast <- prediction |>
    dplyr::filter(.data$type == "forecast")

  counts <- forecast |>
    dplyr::count(
      .data$index,
      .data$variable
    )

  expect_true(
    all(counts$n == length(levels))
  )

  expect_setequal(
    unique(forecast$level),
    levels
  )

  expect_false(
    anyNA(forecast$level)
  )
})


test_that("forecast point estimates are identical across levels", {
  model <- make_predict_varest()

  prediction <- tv_predict(
    model,
    n_ahead = 3,
    level = c(0.50, 0.75, 0.90)
  )

  estimate_counts <- prediction |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::summarise(
      n_estimates = dplyr::n_distinct(.data$estimate),
      .by = c("index", "variable")
    )

  expect_true(
    all(estimate_counts$n_estimates == 1L)
  )
})


test_that("wider confidence levels produce wider nested intervals", {
  model <- make_predict_varest()

  prediction <- tv_predict(
    model,
    n_ahead = 3,
    level = c(0.50, 0.75, 0.90)
  )

  interval_checks <- prediction |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::mutate(
      width = .data$upper - .data$lower
    ) |>
    dplyr::arrange(
      .data$index,
      .data$variable,
      .data$level
    ) |>
    dplyr::summarise(
      width_increases = all(diff(.data$width) > 0),
      lower_expands = all(diff(.data$lower) < 0),
      upper_expands = all(diff(.data$upper) > 0),
      .by = c("index", "variable")
    )

  expect_true(
    all(interval_checks$width_increases)
  )

  expect_true(
    all(interval_checks$lower_expands)
  )

  expect_true(
    all(interval_checks$upper_expands)
  )
})


test_that("confidence intervals contain their point forecasts", {
  model <- make_predict_varest()

  forecast <- tv_predict(
    model,
    n_ahead = 4,
    level = c(0.50, 0.75, 0.90)
  ) |>
    dplyr::filter(.data$type == "forecast")

  expect_true(
    all(forecast$lower <= forecast$estimate)
  )

  expect_true(
    all(forecast$estimate <= forecast$upper)
  )
})


test_that("level must contain finite numeric values", {
  model <- make_predict_varest()

  invalid <- list(
    numeric(),
    NA_real_,
    c(0.80, NA_real_),
    Inf,
    c(0.80, Inf),
    "0.90"
  )

  purrr::walk(invalid, function(level) {
    expect_error(
      tv_predict(
        model,
        n_ahead = 2,
        level = level
      ),
      "`level` must contain one or more finite numeric values"
    )
  })
})


test_that("level values must lie strictly between zero and one", {
  model <- make_predict_varest()

  invalid <- list(
    0,
    1,
    -0.10,
    1.10,
    c(0.50, 1)
  )

  purrr::walk(invalid, function(level) {
    expect_error(
      tv_predict(
        model,
        n_ahead = 2,
        level = level
      ),
      "`level` values must be greater than 0 and less than 1"
    )
  })
})


test_that("level does not accept duplicate values", {
  model <- make_predict_varest()

  expect_error(
    tv_predict(
      model,
      n_ahead = 2,
      level = c(0.90, 0.90)
    ),
    "`level` must not contain duplicate values"
  )
})


test_that("ci is reserved in favour of level", {
  model <- make_predict_varest()

  expect_error(
    tv_predict(
      model,
      n_ahead = 2,
      ci = 0.80
    ),
    "Use `level` to set forecast confidence levels"
  )
})


test_that("irregular Date indices are rejected explicitly", {
  index <- seq.Date(
    as.Date("2020-01-01"),
    by = "month",
    length.out = 24
  )

  index[10] <- index[10] + 2

  model <- make_indexed_predict_varest(index)

  expect_error(
    tv_predict(
      model,
      n_ahead = 3
    ),
    "Cannot infer a regular future index"
  )
})


test_that("arbitrary character indices are not silently replaced", {
  index <- paste0(
    "obs_",
    seq_len(30)
  )

  model <- make_indexed_predict_varest(index)

  expect_error(
    tv_predict(
      model,
      n_ahead = 3
    ),
    "Cannot extend a character index safely"
  )
})


test_that("unsupported classes dispatch to the default method", {
  expect_error(
    tv_predict(
      structure(list(), class = "vec2var"),
      n_ahead = 2
    ),
    regexp = "No .*tv_predict\\(\\).* method"
  )

  expect_error(
    tv_predict(
      matrix(1:10, ncol = 2),
      n_ahead = 2
    ),
    regexp = "No .*tv_predict\\(\\).* method"
  )
})
