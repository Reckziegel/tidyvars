make_autoplot_predict_data <- function() {
  variables <- c("DAX", "CAC")
  levels <- c(0.50, 0.75, 0.90)

  history <- tidyr::expand_grid(
    index = 1:6,
    variable = variables
  ) |>
    dplyr::mutate(
      type = "history",
      level = NA_real_,
      observed = dplyr::if_else(
        .data$variable == "DAX",
        100 + .data$index,
        200 + 2 * .data$index
      ),
      estimate = NA_real_,
      lower = NA_real_,
      upper = NA_real_
    )

  forecast <- tidyr::expand_grid(
    index = 7:9,
    variable = variables,
    level = levels
  ) |>
    dplyr::mutate(
      type = "forecast",
      observed = NA_real_,
      estimate = dplyr::if_else(
        .data$variable == "DAX",
        106 + .data$index - 6,
        212 + 2 * (.data$index - 6)
      ),
      interval_width = dplyr::case_when(
        .data$level == 0.50 ~ 1,
        .data$level == 0.75 ~ 2,
        .data$level == 0.90 ~ 3
      ),
      lower = .data$estimate - .data$interval_width,
      upper = .data$estimate + .data$interval_width
    ) |>
    dplyr::select(-"interval_width")

  dplyr::bind_rows(
    history,
    forecast
  ) |>
    structure(
      class = c(
        "tv_predict",
        "tbl_df",
        "tbl",
        "data.frame"
      )
    )
}


test_that("autoplot.tv_predict() returns a ggplot", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(prediction)

  expect_s3_class(plot, "ggplot")
})


test_that("multiple variables are faceted by variable", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(prediction)

  expect_s3_class(plot$facet, "FacetWrap")
  expect_length(plot$facet$params$facets, 1L)

  expect_identical(
    plot$labels$subtitle,
    "Panels: variable"
  )
})


test_that("a single variable is not faceted", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    .variable = "DAX"
  )

  expect_s3_class(plot$facet, "FacetNull")

  expect_identical(
    plot$labels$subtitle,
    "Variable: DAX"
  )
})


test_that("variable filtering preserves requested variables", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    .variable = "CAC"
  )

  expect_identical(
    unique(as.character(plot$data$variable)),
    "CAC"
  )
})


test_that("forecast intervals are drawn when available", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(prediction)

  expect_length(plot$layers, 3L)
  expect_s3_class(plot$layers[[1]]$geom, "GeomRibbon")
})


test_that("ci = FALSE removes forecast intervals", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    ci = FALSE
  )

  expect_length(plot$layers, 2L)

  geom_classes <- purrr::map_chr(
    plot$layers,
    ~ class(.x$geom)[1]
  )

  expect_false("GeomRibbon" %in% geom_classes)
})


test_that("missing intervals do not produce a ribbon", {
  prediction <- make_autoplot_predict_data() |>
    dplyr::mutate(
      lower = NA_real_,
      upper = NA_real_
    )

  plot <- ggplot2::autoplot(prediction)

  geom_classes <- purrr::map_chr(
    plot$layers,
    ~ class(.x$geom)[1]
  )

  expect_false("GeomRibbon" %in% geom_classes)
})


test_that("autoplot.tv_predict() accepts fixed scales", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    scales = "fixed"
  )

  expect_identical(
    plot$facet$params$free$x,
    FALSE
  )

  expect_identical(
    plot$facet$params$free$y,
    FALSE
  )
})


test_that("autoplot.tv_predict() accepts free y scales", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    scales = "free_y"
  )

  expect_identical(
    plot$facet$params$free$x,
    FALSE
  )

  expect_identical(
    plot$facet$params$free$y,
    TRUE
  )
})


test_that("autoplot.tv_predict() rejects unknown variables", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(
      prediction,
      .variable = "SMI"
    ),
    "Unknown `.variable` value"
  )
})


test_that("autoplot.tv_predict() rejects empty variable filters", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(
      prediction,
      .variable = character()
    ),
    "must contain at least one value"
  )
})


test_that("autoplot.tv_predict() rejects invalid ci values", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(
      prediction,
      ci = "yes"
    ),
    "`ci` must be `TRUE` or `FALSE`"
  )
})


test_that("autoplot.tv_predict() rejects unused arguments", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(
      prediction,
      unused_argument = TRUE
    ),
    "`...` must be empty"
  )
})

test_that("n_history limits historical observations per variable", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 3
  )

  history_data <- plot$data |>
    dplyr::filter(.data$type == "history") |>
    dplyr::count(.data$variable)

  expect_true(all(history_data$n == 3L))
})


test_that("n_history never removes forecast observations", {
  prediction <- make_autoplot_predict_data()

  expected_forecast <- prediction |>
    dplyr::filter(.data$type == "forecast")

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 2
  )

  actual_forecast <- plot$data |>
    dplyr::filter(.data$type == "forecast")

  expect_equal(
    nrow(actual_forecast),
    nrow(expected_forecast)
  )

  expect_identical(
    actual_forecast$index,
    expected_forecast$index
  )
})


test_that("n_history = NULL preserves all historical observations", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = NULL
  )

  expected_n <- prediction |>
    dplyr::filter(.data$type == "history") |>
    nrow()

  actual_n <- plot$data |>
    dplyr::filter(.data$type == "history") |>
    nrow()

  expect_identical(actual_n, expected_n)
})


test_that("n_history larger than available history keeps all observations", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 100
  )

  expect_equal(
    nrow(plot$data),
    nrow(prediction)
  )
})


test_that("autoplot.tv_predict() validates n_history", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(prediction, n_history = 0),
    "`n_history` must be a positive integer or `NULL`"
  )

  expect_error(
    ggplot2::autoplot(prediction, n_history = -1),
    "`n_history` must be a positive integer or `NULL`"
  )

  expect_error(
    ggplot2::autoplot(prediction, n_history = 2.5),
    "`n_history` must be a positive integer or `NULL`"
  )

  expect_error(
    ggplot2::autoplot(prediction, n_history = "20"),
    "`n_history` must be a positive integer or `NULL`"
  )
})

test_that("confidence levels define independent ribbon groups", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(prediction)

  ribbon_layer <- plot$layers[[
    which(
      purrr::map_lgl(
        plot$layers,
        ~ inherits(.x$geom, "GeomRibbon")
      )
    )
  ]]

  expect_true(
    "interval_level" %in% names(ribbon_layer$data)
  )

  expect_identical(
    levels(ribbon_layer$data$interval_level),
    c("90%", "75%", "50%")
  )
})


test_that("forecast line is not duplicated across confidence levels", {
  prediction <- make_autoplot_predict_data()

  plot <- ggplot2::autoplot(prediction)

  line_layers <- plot$layers[
    purrr::map_lgl(
      plot$layers,
      ~ inherits(.x$geom, "GeomLine")
    )
  ]

  forecast_layer <- line_layers[[2]]

  expected <- prediction |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::distinct(
      .data$index,
      .data$variable,
      .data$estimate
    )

  expect_equal(
    nrow(forecast_layer$data),
    nrow(expected)
  )
})


test_that("levels filters confidence intervals without changing forecasts", {
  prediction <- make_autoplot_predict_data()

  all_plot <- ggplot2::autoplot(
    prediction
  )

  selected_plot <- ggplot2::autoplot(
    prediction,
    levels = c(0.50, 0.90)
  )

  selected_ribbon <- selected_plot$layers[[
    which(
      purrr::map_lgl(
        selected_plot$layers,
        ~ inherits(.x$geom, "GeomRibbon")
      )
    )
  ]]

  expect_setequal(
    unique(selected_ribbon$data$level),
    c(0.50, 0.90)
  )

  all_forecast <- all_plot$data |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::distinct(
      .data$index,
      .data$variable,
      .data$estimate
    )

  selected_forecast <- selected_plot$data |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::distinct(
      .data$index,
      .data$variable,
      .data$estimate
    )

  expect_equal(
    selected_forecast,
    all_forecast
  )
})


test_that("autoplot.tv_predict() rejects unavailable confidence levels", {
  prediction <- make_autoplot_predict_data()

  expect_error(
    ggplot2::autoplot(
      prediction,
      levels = 0.99
    ),
    "Unknown `levels`"
  )
})

test_that("autoplot.tv_predict() does not map line colours", {
  data("Canada", package = "vars", envir = environment())

  model <- vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )

  prediction <- tv_predict(
    model,
    n_ahead = 4,
    level = 0.90
  )

  plot <- ggplot2::autoplot(prediction)

  line_layers <- purrr::keep(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomLine")
  )

  expect_length(line_layers, 2L)

  purrr::walk(
    line_layers,
    \(layer) {
      expect_null(layer$mapping$colour)
      expect_null(layer$aes_params$colour)
    }
  )
})


test_that("autoplot.tv_predict() does not map ribbon fill", {
  data("Canada", package = "vars", envir = environment())

  model <- vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )

  prediction <- tv_predict(
    model,
    n_ahead = 4,
    level = 0.90
  )

  plot <- ggplot2::autoplot(prediction)

  ribbon_layers <- purrr::keep(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomRibbon")
  )

  expect_length(ribbon_layers, 1L)

  ribbon <- ribbon_layers[[1]]

  expect_null(ribbon$mapping$fill)
  expect_null(ribbon$aes_params$fill)
})


test_that("autoplot.tv_predict() does not add colour or fill scales", {
  data("Canada", package = "vars", envir = environment())

  model <- vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )

  prediction <- tv_predict(
    model,
    n_ahead = 4,
    level = 0.90
  )

  plot <- ggplot2::autoplot(prediction)

  scale_aesthetics <- plot$scales$scales |>
    purrr::map(\(scale) scale$aesthetics) |>
    unlist(
      use.names = FALSE
    )

  expect_false("colour" %in% scale_aesthetics)
  expect_false("color" %in% scale_aesthetics)
  expect_false("fill" %in% scale_aesthetics)

  expect_true("alpha" %in% scale_aesthetics)
})
