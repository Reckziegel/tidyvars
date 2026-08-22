make_palette_irf <- function() {
  data <- tidyr::expand_grid(
    impulse = c("DAX", "SMI"),
    response = c("DAX", "SMI"),
    horizon = 0:3
  ) |>
    dplyr::mutate(
      estimate = dplyr::if_else(
        .data$impulse == "DAX",
        .data$horizon,
        .data$horizon / 2
      ),
      lower = .data$estimate - 0.5,
      upper = .data$estimate + 0.5
    )

  class(data) <- c(
    "tv_irf",
    class(data)
  )

  data
}


make_palette_fevd <- function() {
  data <- tidyr::expand_grid(
    response = c("DAX", "SMI"),
    shock = c("DAX", "SMI"),
    horizon = 1:3
  ) |>
    dplyr::mutate(
      contribution = dplyr::if_else(
        .data$shock == "DAX",
        0.6,
        0.4
      )
    )

  class(data) <- c(
    "tv_fevd",
    class(data)
  )

  data
}


make_palette_prediction <- function() {
  history <- tidyr::expand_grid(
    variable = c("DAX", "SMI"),
    index = 1:4
  ) |>
    dplyr::mutate(
      type = "history",
      level = NA_real_,
      observed = .data$index +
        dplyr::if_else(
          .data$variable == "SMI",
          5,
          0
        ),
      estimate = NA_real_,
      lower = NA_real_,
      upper = NA_real_
    )

  forecast <- tidyr::expand_grid(
    variable = c("DAX", "SMI"),
    index = 5:7,
    level = c(0.50, 0.90)
  ) |>
    dplyr::mutate(
      type = "forecast",
      observed = NA_real_,
      estimate = .data$index +
        dplyr::if_else(
          .data$variable == "SMI",
          5,
          0
        ),
      lower = .data$estimate - 0.5,
      upper = .data$estimate + 0.5
    )

  data <- dplyr::bind_rows(
    history,
    forecast
  )

  class(data) <- c(
    "tv_predict",
    class(data)
  )

  data
}


test_that("palette_tidyvars() returns a palette component", {
  palette <- palette_tidyvars()

  expect_true(
    S7::S7_inherits(
      palette,
      .tidyvars_palette_class
    )
  )
})


test_that("palette_tidyvars() colours IRFs by impulse", {
  irf <- make_palette_irf()

  plot <- ggplot2::autoplot(
    irf,
    layout = "wrap"
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  line_index <- purrr::detect_index(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomLine")
  )

  expect_setequal(
    unique(built$data[[line_index]]$colour),
    .tidyvars_palette(2)
  )
})


test_that("palette_tidyvars() fills IRF intervals by impulse", {
  irf <- make_palette_irf()

  plot <- ggplot2::autoplot(
    irf,
    layout = "wrap"
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  ribbon_index <- purrr::detect_index(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomRibbon")
  )

  expect_setequal(
    unique(built$data[[ribbon_index]]$fill),
    .tidyvars_palette(2)
  )
})


test_that("palette_tidyvars() leaves IRF zero line neutral", {
  irf <- make_palette_irf()

  plot <- ggplot2::autoplot(
    irf,
    layout = "wrap"
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  hline_index <- purrr::detect_index(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomHline")
  )

  expect_identical(
    unique(built$data[[hline_index]]$colour),
    "black"
  )
})


test_that("palette_tidyvars() colours forecast lines by variable", {
  prediction <- make_palette_prediction()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 4
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  line_indices <- which(
    purrr::map_lgl(
      plot$layers,
      \(layer) inherits(layer$geom, "GeomLine")
    )
  )

  purrr::walk(
    line_indices,
    \(index) {
      expect_setequal(
        unique(built$data[[index]]$colour),
        .tidyvars_palette(2)
      )
    }
  )
})


test_that("palette_tidyvars() fills forecast intervals by variable", {
  prediction <- make_palette_prediction()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 4
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  ribbon_index <- purrr::detect_index(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomRibbon")
  )

  expect_setequal(
    unique(built$data[[ribbon_index]]$fill),
    .tidyvars_palette(2)
  )
})


test_that("palette_tidyvars() preserves forecast confidence alpha", {
  prediction <- make_palette_prediction()

  plot <- ggplot2::autoplot(
    prediction,
    n_history = 4
  ) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  ribbon_index <- purrr::detect_index(
    plot$layers,
    \(layer) inherits(layer$geom, "GeomRibbon")
  )

  expect_gt(
    dplyr::n_distinct(
      built$data[[ribbon_index]]$alpha
    ),
    1L
  )
})


test_that("palette_tidyvars() applies FEVD colours by shock", {
  fevd <- make_palette_fevd()

  plot <- ggplot2::autoplot(fevd) +
    palette_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  expect_setequal(
    unique(built$data[[1]]$fill),
    .tidyvars_palette(2)
  )
})


test_that("palette_tidyvars() does not modify plots until added", {
  prediction <- make_palette_prediction()

  default_plot <- ggplot2::autoplot(
    prediction,
    n_history = 4
  )

  palette_plot <- default_plot +
    palette_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  palette_built <- ggplot2::ggplot_build(
    palette_plot
  )

  line_index <- purrr::detect_index(
    palette_plot$layers,
    \(layer) inherits(layer$geom, "GeomLine")
  )

  expect_false(
    identical(
      default_built$data[[line_index]]$colour,
      palette_built$data[[line_index]]$colour
    )
  )
})


test_that("theme_tidyvars() remains independent from palette_tidyvars()", {
  prediction <- make_palette_prediction()

  default_plot <- ggplot2::autoplot(
    prediction,
    n_history = 4
  )

  themed_plot <- default_plot +
    theme_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  themed_built <- ggplot2::ggplot_build(
    themed_plot
  )

  line_index <- purrr::detect_index(
    themed_plot$layers,
    \(layer) inherits(layer$geom, "GeomLine")
  )

  expect_identical(
    default_built$data[[line_index]]$colour,
    themed_built$data[[line_index]]$colour
  )
})
