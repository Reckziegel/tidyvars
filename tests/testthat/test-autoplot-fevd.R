make_autoplot_fevd_data <- function() {
  tidyr::expand_grid(
    horizon = 1:4,
    response = c("DAX", "CAC"),
    shock = c("DAX", "CAC")
  ) |>
    dplyr::mutate(
      contribution = dplyr::if_else(
        .data$shock == .data$response,
        0.7,
        0.3
      )
    ) |>
    structure(
      class = c("tv_fevd", "tbl_df", "tbl", "data.frame")
    )
}


test_that("autoplot.tv_fevd() returns a ggplot", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(fevd)

  expect_s3_class(plot, "ggplot")
})


test_that("multiple responses are faceted by response", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(fevd)

  expect_s3_class(plot$facet, "FacetWrap")
  expect_length(plot$facet$params$facets, 1L)

  expect_identical(
    plot$labels$subtitle,
    "Panels: response"
  )
})


test_that("a single response is not faceted", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(
    fevd,
    .response = "DAX"
  )

  expect_s3_class(plot$facet, "FacetNull")

  expect_identical(
    plot$labels$subtitle,
    "Response: DAX"
  )
})


test_that("response filtering preserves the requested responses", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(
    fevd,
    .response = "CAC"
  )

  expect_identical(
    unique(as.character(plot$data$response)),
    "CAC"
  )
})


test_that("shock filtering does not renormalize contributions", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(
    fevd,
    .response = "DAX",
    .shock = "CAC"
  )

  expect_true(all(plot$data$contribution == 0.3))
})


test_that("FEVD plots use a zero-to-one visual range", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(fevd)

  expect_null(
    plot$scales$get_scales("y")$limits
  )

  expect_identical(
    plot$coordinates$limits$y,
    c(0, 1)
  )
})


test_that("shock order follows the tv_fevd object", {
  fevd <- make_autoplot_fevd_data()

  plot <- ggplot2::autoplot(fevd)

  expect_identical(
    levels(plot$data$shock),
    c("DAX", "CAC")
  )
})


test_that("autoplot.tv_fevd() rejects unknown responses", {
  fevd <- make_autoplot_fevd_data()

  expect_error(
    ggplot2::autoplot(
      fevd,
      .response = "SMI"
    ),
    "Unknown `.response` value"
  )
})


test_that("autoplot.tv_fevd() rejects unknown shocks", {
  fevd <- make_autoplot_fevd_data()

  expect_error(
    ggplot2::autoplot(
      fevd,
      .shock = "SMI"
    ),
    "Unknown `.shock` value"
  )
})


test_that("autoplot.tv_fevd() rejects empty response filters", {
  fevd <- make_autoplot_fevd_data()

  expect_error(
    ggplot2::autoplot(
      fevd,
      .response = character()
    ),
    "must contain at least one value"
  )
})


test_that("autoplot.tv_fevd() rejects empty shock filters", {
  fevd <- make_autoplot_fevd_data()

  expect_error(
    ggplot2::autoplot(
      fevd,
      .shock = character()
    ),
    "must contain at least one value"
  )
})


test_that("autoplot.tv_fevd() rejects unused arguments", {
  fevd <- make_autoplot_fevd_data()

  expect_error(
    ggplot2::autoplot(
      fevd,
      unused_argument = TRUE
    ),
    "`...` must be empty"
  )
})
