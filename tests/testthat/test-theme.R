test_that("theme_tidyvars() returns a ggplot2 theme", {
  theme <- theme_tidyvars()

  expect_s3_class(theme, "theme")
})


test_that("theme_tidyvars() uses the requested base size", {
  theme <- theme_tidyvars(base_size = 14)

  text <- ggplot2::calc_element(
    "text",
    theme
  )

  expect_equal(text$size, 14)
})


test_that("theme_tidyvars() uses the requested base family", {
  theme <- theme_tidyvars(base_family = "sans")

  text <- ggplot2::calc_element(
    "text",
    theme
  )

  expect_identical(text$family, "sans")
})


test_that("theme_tidyvars() does not change unmapped geom colours", {
  data <- tibble::tibble(
    x = 1:3,
    y = 1:3
  )

  default_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$x,
      y = .data$y
    )
  ) +
    ggplot2::geom_line()

  themed_plot <- default_plot +
    theme_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  themed_built <- ggplot2::ggplot_build(
    themed_plot
  )

  expect_identical(
    default_built$data[[1]]$colour,
    themed_built$data[[1]]$colour
  )
})


test_that("theme_tidyvars() does not change mapped discrete colours", {
  data <- tibble::tibble(
    x = 1:4,
    y = 1:4,
    group = factor(c("a", "a", "b", "b"))
  )

  default_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$x,
      y = .data$y,
      colour = .data$group
    )
  ) +
    ggplot2::geom_line()

  themed_plot <- default_plot +
    theme_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  themed_built <- ggplot2::ggplot_build(
    themed_plot
  )

  expect_identical(
    default_built$data[[1]]$colour,
    themed_built$data[[1]]$colour
  )
})


test_that("theme_tidyvars() does not change mapped discrete fills", {
  data <- tibble::tibble(
    group = factor(c("a", "b", "c")),
    value = c(1, 2, 3)
  )

  default_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$group,
      y = .data$value,
      fill = .data$group
    )
  ) +
    ggplot2::geom_col()

  themed_plot <- default_plot +
    theme_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  themed_built <- ggplot2::ggplot_build(
    themed_plot
  )

  expect_identical(
    default_built$data[[1]]$fill,
    themed_built$data[[1]]$fill
  )
})


test_that("theme_tidyvars() uses a white plot background", {
  theme <- theme_tidyvars()

  expect_identical(
    theme$plot.background$fill,
    "white"
  )

  expect_true(
    is.na(theme$plot.background$colour)
  )
})


test_that("theme_tidyvars() uses a subtle major grid", {
  theme <- theme_tidyvars()

  expect_s3_class(
    theme$panel.grid.major,
    "element_line"
  )

  expect_identical(
    theme$panel.grid.major$colour,
    "#DCE2E7"
  )

  expect_equal(
    theme$panel.grid.major$linewidth,
    0.35
  )
})


test_that("theme_tidyvars() removes minor grid lines", {
  theme <- theme_tidyvars()

  expect_s3_class(
    theme$panel.grid.minor,
    "element_blank"
  )
})


test_that("theme_tidyvars() adds spacing between panels", {
  theme <- theme_tidyvars()

  expect_equal(
    as.numeric(theme$panel.spacing),
    10
  )

  expect_identical(
    attr(theme$panel.spacing, "unit"),
    8L
  )
})


test_that("theme_tidyvars() uses clean facet strips", {
  theme <- theme_tidyvars()

  expect_s3_class(
    theme$strip.background,
    "element_blank"
  )

  expect_identical(
    theme$strip.text$face,
    "bold"
  )

  expect_identical(
    theme$strip.text$colour,
    "#20262E"
  )
})


test_that("theme_tidyvars() places the legend at the bottom", {
  theme <- theme_tidyvars()

  expect_identical(
    theme$legend.position,
    "bottom"
  )
})


test_that("theme_tidyvars() removes axis ticks", {
  theme <- theme_tidyvars()

  expect_s3_class(
    theme$axis.ticks,
    "element_blank"
  )
})


test_that("theme_tidyvars() can be added to a ggplot", {
  plot <- ggplot2::ggplot(
    mtcars,
    ggplot2::aes(
      x = .data$wt,
      y = .data$mpg
    )
  ) +
    ggplot2::geom_point() +
    theme_tidyvars()

  expect_s3_class(plot, "ggplot")
})


test_that("theme_tidyvars() does not modify global ggplot2 theme", {
  before <- ggplot2::theme_get()

  theme_tidyvars()

  after <- ggplot2::theme_get()

  expect_identical(
    after,
    before
  )
})


test_that("theme_tidyvars() rejects invalid base sizes", {
  expect_error(
    theme_tidyvars(base_size = 0),
    "`base_size` must be a positive numeric scalar",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_size = -1),
    "`base_size` must be a positive numeric scalar",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_size = NA_real_),
    "`base_size` must be a positive numeric scalar",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_size = c(10, 11)),
    "`base_size` must be a positive numeric scalar",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_size = "11"),
    "`base_size` must be a positive numeric scalar",
    fixed = TRUE
  )
})


test_that("theme_tidyvars() rejects invalid base families", {
  expect_error(
    theme_tidyvars(base_family = NA_character_),
    "`base_family` must be a single character string",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_family = c("sans", "serif")),
    "`base_family` must be a single character string",
    fixed = TRUE
  )

  expect_error(
    theme_tidyvars(base_family = 1),
    "`base_family` must be a single character string",
    fixed = TRUE
  )
})
