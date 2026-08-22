
make_autoplot_irf_varest <- function() {
  data("Canada", package = "vars", envir = environment())

  vars::VAR(
    get("Canada", envir = environment()),
    p = 2,
    type = "const"
  )
}

has_geom <- function(plot, geom_class) {
  any(
    vapply(
      plot$layers,
      \(layer) inherits(layer$geom, geom_class),
      logical(1)
    )
  )
}


test_that("autoplot.tv_irf() returns a ggplot", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  plot <- ggplot2::autoplot(result)

  expect_true(ggplot2::is_ggplot(plot))
})


test_that("autoplot.tv_irf() uses a grid for many-to-many IRFs", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  plot <- ggplot2::autoplot(result)

  expect_true(inherits(plot$facet, "FacetGrid"))

  expect_identical(
    plot$labels$subtitle,
    "Columns: impulse | Rows: response"
  )
})


test_that("autoplot.tv_irf() wraps responses for one impulse", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  impulse <- unique(result$impulse)[[1]]

  plot <- ggplot2::autoplot(
    result,
    .impulse = impulse
  )

  expect_true(inherits(plot$facet, "FacetWrap"))
  expect_true(all(as.character(plot$data$impulse) == impulse))

  expect_identical(
    plot$labels$subtitle,
    paste0("Impulse: ", impulse)
  )
})


test_that("autoplot.tv_irf() wraps impulses for one response", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  response <- unique(result$response)[[1]]

  plot <- ggplot2::autoplot(
    result,
    .response = response
  )

  expect_true(inherits(plot$facet, "FacetWrap"))
  expect_true(all(as.character(plot$data$response) == response))

  expect_identical(
    plot$labels$subtitle,
    paste0("Response: ", response)
  )
})


test_that("autoplot.tv_irf() does not facet one-to-one IRFs", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  impulse <- unique(result$impulse)[[1]]
  response <- unique(result$response)[[1]]

  plot <- ggplot2::autoplot(
    result,
    .impulse = impulse,
    .response = response
  )

  expect_true(inherits(plot$facet, "FacetNull"))

  expect_identical(
    plot$labels$subtitle,
    paste0(
      "Impulse: ",
      impulse,
      " \u2192 Response: ",
      response
    )
  )
})


test_that("layout can be selected explicitly", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  grid_plot <- ggplot2::autoplot(
    result,
    layout = "grid"
  )

  wrap_plot <- ggplot2::autoplot(
    result,
    layout = "wrap"
  )

  expect_true(inherits(grid_plot$facet, "FacetGrid"))
  expect_true(inherits(wrap_plot$facet, "FacetWrap"))
})


test_that("autoplot.tv_irf() preserves IRF values", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  plot <- ggplot2::autoplot(result)

  expect_equal(nrow(plot$data), nrow(result))
  expect_equal(plot$data$horizon, result$horizon)
  expect_equal(plot$data$estimate, result$estimate)
  expect_equal(plot$data$lower, result$lower)
  expect_equal(plot$data$upper, result$upper)
})


test_that("visual ordering does not modify the tv_irf object", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  expect_type(result$impulse, "character")
  expect_type(result$response, "character")

  plot <- ggplot2::autoplot(result)

  expect_true(is.factor(plot$data$impulse))
  expect_true(is.factor(plot$data$response))

  expect_type(result$impulse, "character")
  expect_type(result$response, "character")

  expect_identical(
    levels(plot$data$impulse),
    unique(result$impulse)
  )

  expect_identical(
    levels(plot$data$response),
    unique(result$response)
  )
})


test_that("autoplot.tv_irf() filters multiple impulses and responses", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  impulses <- unique(result$impulse)[1:2]
  responses <- unique(result$response)[1:2]

  plot <- ggplot2::autoplot(
    result,
    .impulse = impulses,
    .response = responses
  )

  expect_setequal(
    unique(as.character(plot$data$impulse)),
    impulses
  )

  expect_setequal(
    unique(as.character(plot$data$response)),
    responses
  )

  expect_equal(
    nrow(plot$data),
    sum(
      result$impulse %in% impulses &
        result$response %in% responses
    )
  )
})


test_that("autoplot.tv_irf() preserves all horizons", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 6, boot = FALSE)

  plot <- ggplot2::autoplot(result)

  expect_equal(
    sort(unique(plot$data$horizon)),
    0:6
  )
})


test_that("IRFs without intervals do not add a ribbon", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  expect_true(all(is.na(result$lower)))
  expect_true(all(is.na(result$upper)))

  plot <- ggplot2::autoplot(result)

  expect_false(has_geom(plot, "GeomRibbon"))
  expect_true(has_geom(plot, "GeomLine"))

  expect_no_error(
    ggplot2::ggplot_build(plot)
  )
})


test_that("IRFs with intervals add a ribbon by default", {
  model <- make_autoplot_irf_varest()

  result <- tv_irf(
    model,
    n.ahead = 3,
    boot = TRUE,
    runs = 20,
    seed = 123
  )

  plot <- ggplot2::autoplot(result)

  expect_true(has_geom(plot, "GeomRibbon"))
  expect_true(has_geom(plot, "GeomLine"))

  expect_no_error(
    ggplot2::ggplot_build(plot)
  )
})


test_that("ci = FALSE hides available confidence intervals", {
  model <- make_autoplot_irf_varest()

  result <- tv_irf(
    model,
    n.ahead = 3,
    boot = TRUE,
    runs = 20,
    seed = 123
  )

  plot <- ggplot2::autoplot(
    result,
    ci = FALSE
  )

  expect_false(has_geom(plot, "GeomRibbon"))
  expect_true(has_geom(plot, "GeomLine"))
})


test_that("autoplot.tv_irf() rejects unknown impulses", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 3, boot = FALSE)

  expect_error(
    ggplot2::autoplot(
      result,
      .impulse = "not_an_impulse"
    ),
    "Unknown"
  )
})


test_that("autoplot.tv_irf() rejects unknown responses", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 3, boot = FALSE)

  expect_error(
    ggplot2::autoplot(
      result,
      .response = "not_a_response"
    ),
    "Unknown"
  )
})


test_that("autoplot.tv_irf() validates ci", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 3, boot = FALSE)

  expect_error(
    ggplot2::autoplot(result, ci = "yes"),
    "must be `TRUE` or `FALSE`"
  )
})


test_that("autoplot.tv_irf() validates layout and scales", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 3, boot = FALSE)

  expect_error(
    ggplot2::autoplot(result, layout = "matrix")
  )

  expect_error(
    ggplot2::autoplot(result, scales = "free")
  )
})


test_that("wrap layout has an informative subtitle for many-to-many IRFs", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 4, boot = FALSE)

  plot <- ggplot2::autoplot(
    result,
    layout = "wrap"
  )

  expect_true(inherits(plot$facet, "FacetWrap"))

  expect_identical(
    plot$labels$subtitle,
    "Panels: impulse \u2192 response"
  )
})


test_that("autoplot.tv_irf generic is available through ggplot2", {
  model <- make_autoplot_irf_varest()
  result <- tv_irf(model, n.ahead = 2, boot = FALSE)

  expect_no_error(
    ggplot2::autoplot(result)
  )
})

make_autoplot_irf_data <- function() {
  tidyr::expand_grid(
    horizon = 0:4,
    impulse = c("DAX", "CAC"),
    response = c("DAX", "CAC")
  ) |>
    dplyr::mutate(
      estimate = 0.1 * exp(-0.4 * .data$horizon),
      lower = .data$estimate - 0.05,
      upper = .data$estimate + 0.05
    ) |>
    structure(
      class = c("tv_irf", "tbl_df", "tbl", "data.frame")
    )
}


test_that("wrap uses a single directional strip for many-to-many IRFs", {
  irf <- make_autoplot_irf_data()

  plot <- ggplot2::autoplot(
    irf,
    layout = "wrap"
  )

  expect_s3_class(plot$facet, "FacetWrap")
  expect_length(plot$facet$params$facets, 1L)

  expect_true("panel_label" %in% names(plot$data))

  expected_labels <- plot$data |>
    dplyr::distinct(.data$impulse, .data$response) |>
    dplyr::transmute(
      label = paste(
        as.character(.data$impulse),
        as.character(.data$response),
        sep = " \u2192 "
      )
    ) |>
    dplyr::pull(.data$label)

  expect_identical(
    levels(plot$data$panel_label),
    expected_labels
  )

  expect_identical(
    plot$labels$subtitle,
    "Panels: impulse \u2192 response"
  )
})


test_that("one-to-one IRFs are not faceted", {
  irf <- make_autoplot_irf_data()

  one_irf <- irf |>
    dplyr::filter(
      .data$impulse == "DAX",
      .data$response == "CAC"
    )

  auto_plot <- ggplot2::autoplot(one_irf)
  wrap_plot <- ggplot2::autoplot(one_irf, layout = "wrap")
  grid_plot <- ggplot2::autoplot(one_irf, layout = "grid")

  expect_s3_class(auto_plot$facet, "FacetNull")
  expect_s3_class(wrap_plot$facet, "FacetNull")
  expect_s3_class(grid_plot$facet, "FacetNull")
})


test_that("wrap keeps response facets for one-to-many IRFs", {
  irf <- make_autoplot_irf_data()

  plot <- ggplot2::autoplot(
    irf,
    .impulse = "DAX",
    layout = "wrap"
  )

  expect_s3_class(plot$facet, "FacetWrap")
  expect_length(plot$facet$params$facets, 1L)

  expect_false("panel_label" %in% names(plot$data))

  expect_identical(
    plot$labels$subtitle,
    "Impulse: DAX"
  )
})


test_that("wrap keeps impulse facets for many-to-one IRFs", {
  irf <- make_autoplot_irf_data()

  plot <- ggplot2::autoplot(
    irf,
    .response = "CAC",
    layout = "wrap"
  )

  expect_s3_class(plot$facet, "FacetWrap")
  expect_length(plot$facet$params$facets, 1L)

  expect_false("panel_label" %in% names(plot$data))

  expect_identical(
    plot$labels$subtitle,
    "Response: CAC"
  )
})


test_that("autoplot.tv_irf() rejects unused arguments", {
  irf <- make_autoplot_irf_data()

  expect_error(
    ggplot2::autoplot(
      irf,
      unused_argument = TRUE
    ),
    "`...` must be empty"
  )
})
