.tidyvars_colors <- c(
  deep_blue = "#24527A",
  teal = "#3A7D78",
  ochre = "#C08A3E",
  brick = "#A6534A",
  purple = "#75658C",
  steel = "#607987",
  olive = "#7A8B55",
  rose = "#B66B78",
  indigo = "#4F6293",
  rust = "#A66B3F",
  sage = "#6F8A70",
  plum = "#8B657D"
)


.tidyvars_palette <- function(n) {
  colors <- unname(.tidyvars_colors)

  if (n <= length(colors)) {
    return(colors[seq_len(n)])
  }

  grDevices::colorRampPalette(colors)(n)
}


.tidyvars_palette_class <- S7::new_class(
  "tidyvars_palette",
  package = "tidyvars"
)


.tidyvars_palette_plot_type <- function(plot) {
  columns <- names(plot$data)

  if (
    all(
      c(
        "horizon",
        "impulse",
        "response",
        "estimate"
      ) %in% columns
    )
  ) {
    return("irf")
  }

  if (
    all(
      c(
        "index",
        "variable",
        "type",
        "estimate"
      ) %in% columns
    )
  ) {
    return("predict")
  }

  if (
    all(
      c(
        "horizon",
        "response",
        "shock",
        "contribution"
      ) %in% columns
    )
  ) {
    return("fevd")
  }

  "default"
}


.tidyvars_add_layer_mapping <- function(
    layer,
    aesthetic,
    variable
) {
  mapping <- switch(
    aesthetic,
    colour = ggplot2::aes(
      colour = .data[[variable]]
    ),
    fill = ggplot2::aes(
      fill = .data[[variable]]
    )
  )

  layer$mapping[[aesthetic]] <- mapping[[aesthetic]]

  layer
}


.tidyvars_map_geom <- function(
    plot,
    geom_class,
    aesthetic,
    variable
) {
  plot$layers <- purrr::map(
    plot$layers,
    \(layer) {
      if (!inherits(layer$geom, geom_class)) {
        return(layer)
      }

      .tidyvars_add_layer_mapping(
        layer = layer,
        aesthetic = aesthetic,
        variable = variable
      )
    }
  )

  plot
}


#' tidyvars discrete colour scales
#'
#' Discrete colour and fill scales designed for econometric and financial
#' graphics produced with tidyvars.
#'
#' `scale_color_tidyvars()` controls mapped `colour` aesthetics, while
#' `scale_fill_tidyvars()` controls mapped `fill` aesthetics.
#'
#' These scales are independent from [theme_tidyvars()]. Applying the theme
#' does not modify data colours.
#'
#' @param ... Additional arguments passed to [ggplot2::discrete_scale()].
#' @param na.value Colour used for missing values.
#'
#' @return A discrete ggplot2 scale.
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(
#'   mtcars,
#'   aes(wt, mpg, colour = factor(cyl))
#' ) +
#'   geom_point(size = 3) +
#'   scale_color_tidyvars()
#'
#' ggplot(
#'   mtcars,
#'   aes(factor(cyl), fill = factor(gear))
#' ) +
#'   geom_bar() +
#'   scale_fill_tidyvars()
#'
#' @export
scale_color_tidyvars <- function(
    ...,
    na.value = "grey70"
) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = .tidyvars_palette,
    na.value = na.value,
    ...
  )
}


#' @rdname scale_color_tidyvars
#' @export
scale_fill_tidyvars <- function(
    ...,
    na.value = "grey70"
) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = .tidyvars_palette,
    na.value = na.value,
    ...
  )
}


#' tidyvars colour palette
#'
#' Apply the tidyvars colour identity to a ggplot.
#'
#' `palette_tidyvars()` complements [theme_tidyvars()] by applying the
#' tidyvars colour system to the data layers of a plot.
#'
#' For plots produced by tidyvars, the palette uses the natural categorical
#' dimension of each visualization:
#'
#' * impulse response functions are coloured by impulse;
#' * forecasts are coloured by variable;
#' * forecast error variance decompositions are filled by shock.
#'
#' The function is entirely optional. Plots produced by tidyvars retain their
#' standard ggplot2 colours unless `palette_tidyvars()` is explicitly added.
#'
#' @return A palette component that can be added to a ggplot object.
#'
#' @examples
#' library(ggplot2)
#'
#' model <- vars::VAR(
#'   EuStockMarkets,
#'   p = 2
#' )
#'
#' autoplot(tv_irf(model), layout = "wrap") +
#'   theme_tidyvars() +
#'   palette_tidyvars()
#'
#' autoplot(tv_fevd(model)) +
#'   theme_tidyvars() +
#'   palette_tidyvars()
#'
#' @export
palette_tidyvars <- function() {
  .tidyvars_palette_class()
}


#' @importFrom ggplot2 update_ggplot class_ggplot
NULL


S7::method(
  update_ggplot,
  list(
    .tidyvars_palette_class,
    class_ggplot
  )
) <- function(object, plot, ...) {
  plot_type <- .tidyvars_palette_plot_type(plot)

  if (plot_type == "irf") {
    plot <- .tidyvars_map_geom(
      plot = plot,
      geom_class = "GeomLine",
      aesthetic = "colour",
      variable = "impulse"
    )

    plot <- .tidyvars_map_geom(
      plot = plot,
      geom_class = "GeomRibbon",
      aesthetic = "fill",
      variable = "impulse"
    )

    return(
      plot +
        scale_color_tidyvars() +
        scale_fill_tidyvars() +
        ggplot2::guides(
          colour = "none",
          fill = "none"
        )
    )
  }

  if (plot_type == "predict") {
    plot <- .tidyvars_map_geom(
      plot = plot,
      geom_class = "GeomLine",
      aesthetic = "colour",
      variable = "variable"
    )

    plot <- .tidyvars_map_geom(
      plot = plot,
      geom_class = "GeomRibbon",
      aesthetic = "fill",
      variable = "variable"
    )

    return(
      plot +
        scale_color_tidyvars() +
        scale_fill_tidyvars() +
        ggplot2::guides(
          colour = "none",
          fill = "none"
        )
    )
  }

  if (plot_type == "fevd") {
    return(
      plot +
        scale_fill_tidyvars()
    )
  }

  plot +
    scale_color_tidyvars() +
    scale_fill_tidyvars()
}
