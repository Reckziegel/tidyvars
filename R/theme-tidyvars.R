.validate_theme_base_size <- function(base_size) {
  is_valid <- is.numeric(base_size) &&
    length(base_size) == 1L &&
    !is.na(base_size) &&
    is.finite(base_size) &&
    base_size > 0

  if (!is_valid) {
    cli::cli_abort(
      "{.arg base_size} must be a positive numeric scalar."
    )
  }

  invisible(base_size)
}


.validate_theme_base_family <- function(base_family) {
  is_valid <- is.character(base_family) &&
    length(base_family) == 1L &&
    !is.na(base_family)

  if (!is_valid) {
    cli::cli_abort(
      "{.arg base_family} must be a single character string."
    )
  }

  invisible(base_family)
}


#' tidyvars ggplot2 theme
#'
#' A clean and professional ggplot2 theme designed for econometric and
#' financial graphics.
#'
#' `theme_tidyvars()` controls the structural appearance of a plot, including
#' typography, grid lines, facet strips, legends, spacing, and margins.
#'
#' The theme does not modify data colours or discrete colour palettes. Colour
#' styling is handled separately by the tidyvars colour and fill scales.
#'
#' @param base_size Base font size in points. Must be a positive numeric
#'   scalar.
#' @param base_family Base font family. The default, `""`, uses the default
#'   graphics device font.
#'
#' @return A complete ggplot2 theme.
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(
#'   mtcars,
#'   aes(wt, mpg)
#' ) +
#'   geom_point() +
#'   labs(
#'     title = "Fuel economy and vehicle weight",
#'     subtitle = "Motor Trend road tests",
#'     x = "Weight",
#'     y = "Miles per gallon"
#'   ) +
#'   theme_tidyvars()
#'
#' @export
theme_tidyvars <- function(
    base_size = 11,
    base_family = ""
) {
  .validate_theme_base_size(base_size)
  .validate_theme_base_family(base_family)

  ggplot2::theme_minimal(
    base_size = base_size,
    base_family = base_family
  ) +
    ggplot2::theme(
      text = ggplot2::element_text(
        colour = "#20262E"
      ),
      plot.background = ggplot2::element_rect(
        fill = "white",
        colour = NA
      ),
      panel.background = ggplot2::element_rect(
        fill = "white",
        colour = NA
      ),
      plot.title = ggplot2::element_text(
        colour = "#20262E",
        face = "bold",
        size = ggplot2::rel(1.30),
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "#59636E",
        size = ggplot2::rel(0.95),
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        colour = "#737D86",
        size = ggplot2::rel(0.80),
        margin = ggplot2::margin(t = 10)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title = ggplot2::element_text(
        colour = "#39434C",
        size = ggplot2::rel(0.95)
      ),
      axis.title.x = ggplot2::element_text(
        margin = ggplot2::margin(t = 9)
      ),
      axis.title.y = ggplot2::element_text(
        margin = ggplot2::margin(r = 9)
      ),
      axis.text = ggplot2::element_text(
        colour = "#59636E",
        size = ggplot2::rel(0.88)
      ),
      axis.ticks = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(
        colour = "#DCE2E7",
        linewidth = 0.35
      ),
      panel.grid.minor = ggplot2::element_blank(),
      panel.spacing = grid::unit(
        10,
        "pt"
      ),
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(
        colour = "#20262E",
        face = "bold",
        size = ggplot2::rel(0.92),
        margin = ggplot2::margin(
          t = 5,
          r = 4,
          b = 7,
          l = 4
        )
      ),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(
        colour = "#39434C",
        face = "bold",
        size = ggplot2::rel(0.88)
      ),
      legend.text = ggplot2::element_text(
        colour = "#59636E",
        size = ggplot2::rel(0.86)
      ),
      legend.key = ggplot2::element_blank(),
      legend.spacing.x = grid::unit(
        4,
        "pt"
      ),
      legend.box.spacing = grid::unit(
        8,
        "pt"
      ),
      plot.margin = ggplot2::margin(
        t = 12,
        r = 14,
        b = 12,
        l = 12
      )
    )
}
