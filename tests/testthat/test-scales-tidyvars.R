test_that("tidyvars palette preserves its core colours", {
  expect_identical(
    .tidyvars_palette(4),
    unname(.tidyvars_colors[1:4])
  )
})


test_that("tidyvars palette returns the requested number of colours", {
  expect_length(
    .tidyvars_palette(1),
    1L
  )

  expect_length(
    .tidyvars_palette(6),
    6L
  )

  expect_length(
    .tidyvars_palette(12),
    12L
  )
})


test_that("tidyvars palette supports more than twelve colours", {
  colors <- .tidyvars_palette(16)

  expect_length(
    colors,
    16L
  )

  expect_true(
    all(grepl("^#[0-9A-Fa-f]{6}$", colors))
  )
})


test_that("scale_color_tidyvars() returns a discrete colour scale", {
  scale <- scale_color_tidyvars()

  expect_s3_class(
    scale,
    "ScaleDiscrete"
  )

  expect_identical(
    scale$aesthetics,
    "colour"
  )
})


test_that("scale_fill_tidyvars() returns a discrete fill scale", {
  scale <- scale_fill_tidyvars()

  expect_s3_class(
    scale,
    "ScaleDiscrete"
  )

  expect_identical(
    scale$aesthetics,
    "fill"
  )
})


test_that("scale_color_tidyvars() uses tidyvars colours", {
  data <- tibble::tibble(
    x = 1:3,
    y = 1:3,
    group = factor(c("a", "b", "c"))
  )

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$x,
      y = .data$y,
      colour = .data$group
    )
  ) +
    ggplot2::geom_point() +
    scale_color_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  expect_setequal(
    unique(built$data[[1]]$colour),
    .tidyvars_palette(3)
  )
})


test_that("scale_fill_tidyvars() uses tidyvars colours", {
  data <- tibble::tibble(
    group = factor(c("a", "b", "c")),
    value = c(1, 2, 3)
  )

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$group,
      y = .data$value,
      fill = .data$group
    )
  ) +
    ggplot2::geom_col() +
    scale_fill_tidyvars()

  built <- ggplot2::ggplot_build(plot)

  expect_setequal(
    unique(built$data[[1]]$fill),
    .tidyvars_palette(3)
  )
})


test_that("scale_color_tidyvars() changes colours only when applied", {
  data <- tibble::tibble(
    x = 1:3,
    y = 1:3,
    group = factor(c("a", "b", "c"))
  )

  default_plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$x,
      y = .data$y,
      colour = .data$group
    )
  ) +
    ggplot2::geom_point()

  tidyvars_plot <- default_plot +
    scale_color_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  tidyvars_built <- ggplot2::ggplot_build(
    tidyvars_plot
  )

  expect_false(
    identical(
      default_built$data[[1]]$colour,
      tidyvars_built$data[[1]]$colour
    )
  )

  expect_setequal(
    unique(tidyvars_built$data[[1]]$colour),
    .tidyvars_palette(3)
  )
})


test_that("scale_fill_tidyvars() changes fills only when applied", {
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

  tidyvars_plot <- default_plot +
    scale_fill_tidyvars()

  default_built <- ggplot2::ggplot_build(
    default_plot
  )

  tidyvars_built <- ggplot2::ggplot_build(
    tidyvars_plot
  )

  expect_false(
    identical(
      default_built$data[[1]]$fill,
      tidyvars_built$data[[1]]$fill
    )
  )

  expect_setequal(
    unique(tidyvars_built$data[[1]]$fill),
    .tidyvars_palette(3)
  )
})


test_that("tidyvars scales work independently from theme_tidyvars()", {
  data <- tibble::tibble(
    x = 1:3,
    y = 1:3,
    group = factor(c("a", "b", "c"))
  )

  scale_only <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = .data$x,
      y = .data$y,
      colour = .data$group
    )
  ) +
    ggplot2::geom_point() +
    scale_color_tidyvars()

  scale_and_theme <- scale_only +
    theme_tidyvars()

  scale_only_built <- ggplot2::ggplot_build(
    scale_only
  )

  scale_and_theme_built <- ggplot2::ggplot_build(
    scale_and_theme
  )

  expect_identical(
    scale_only_built$data[[1]]$colour,
    scale_and_theme_built$data[[1]]$colour
  )
})


test_that("tidyvars scales accept standard scale arguments", {
  color_scale <- scale_color_tidyvars(
    name = "Series",
    limits = c("a", "b")
  )

  fill_scale <- scale_fill_tidyvars(
    name = "Shock",
    limits = c("a", "b")
  )

  expect_identical(
    color_scale$name,
    "Series"
  )

  expect_identical(
    fill_scale$name,
    "Shock"
  )

  expect_identical(
    color_scale$limits,
    c("a", "b")
  )

  expect_identical(
    fill_scale$limits,
    c("a", "b")
  )
})


test_that("tidyvars scales allow custom missing-value colours", {
  color_scale <- scale_color_tidyvars(
    na.value = "black"
  )

  fill_scale <- scale_fill_tidyvars(
    na.value = "black"
  )

  expect_identical(
    color_scale$na.value,
    "black"
  )

  expect_identical(
    fill_scale$na.value,
    "black"
  )
})
