#' Autoplot tidyvars objects
#'
#' @param object A tidyvars object.
#' @param .impulse Optional impulse variables to display.
#' @param .response Optional response variables to display.
#' @param layout Facet layout. One of `"auto"`, `"grid"`, or `"wrap"`.
#' @param scales Scale behaviour across facets. One of `"free_y"` or
#'   `"fixed"`.
#' @param ci Whether to display confidence intervals when available.
#' @param ... Additional arguments reserved for future use.
#'
#' @return A `ggplot` object.
#'
#' @importFrom ggplot2 autoplot
#' @export
autoplot.tv_irf <- function(
    object,
    .impulse = NULL,
    .response = NULL,
    layout = c("auto", "grid", "wrap"),
    scales = c("free_y", "fixed"),
    ci = TRUE,
    ...
) {
  rlang::check_dots_empty()

  layout <- rlang::arg_match(layout, c("auto", "grid", "wrap"))
  scales <- rlang::arg_match(scales, c("free_y", "fixed"))

  if (!rlang::is_bool(ci)) {
    cli::cli_abort("{.arg ci} must be `TRUE` or `FALSE`.")
  }

  available_impulses <- unique(object$impulse)
  available_responses <- unique(object$response)

  if (!is.null(.impulse)) {
    if (length(.impulse) == 0L) {
      cli::cli_abort("{.arg .impulse} must contain at least one value.")
    }

    unknown_impulses <- setdiff(.impulse, available_impulses)

    if (length(unknown_impulses) > 0L) {
      noun <- if (length(unknown_impulses) == 1L) "value" else "values"

      cli::cli_abort(
        c(
          "Unknown {.arg .impulse} {noun}.",
          "x" = "Unknown: {.val {unknown_impulses}}.",
          "i" = "Available: {.val {available_impulses}}."
        )
      )
    }
  }

  if (!is.null(.response)) {
    if (length(.response) == 0L) {
      cli::cli_abort("{.arg .response} must contain at least one value.")
    }

    unknown_responses <- setdiff(.response, available_responses)

    if (length(unknown_responses) > 0L) {
      noun <- if (length(unknown_responses) == 1L) "value" else "values"

      cli::cli_abort(
        c(
          "Unknown {.arg .response} {noun}.",
          "x" = "Unknown: {.val {unknown_responses}}.",
          "i" = "Available: {.val {available_responses}}."
        )
      )
    }
  }

  plot_data <- object

  if (!is.null(.impulse)) {
    plot_data <- plot_data |>
      dplyr::filter(.data$impulse %in% .env$.impulse)
  }

  if (!is.null(.response)) {
    plot_data <- plot_data |>
      dplyr::filter(.data$response %in% .env$.response)
  }

  plot_data <- plot_data |>
    dplyr::mutate(
      impulse = factor(.data$impulse, levels = available_impulses),
      response = factor(.data$response, levels = available_responses)
    )

  n_impulses <- dplyr::n_distinct(plot_data$impulse)
  n_responses <- dplyr::n_distinct(plot_data$response)

  resolved_layout <- layout

  if (n_impulses == 1L && n_responses == 1L) {
    resolved_layout <- "none"
  } else if (layout == "auto") {
    if (n_impulses > 1L && n_responses > 1L) {
      resolved_layout <- "grid"
    } else {
      resolved_layout <- "wrap"
    }
  }

  if (
    resolved_layout == "wrap" &&
    n_impulses > 1L &&
    n_responses > 1L
  ) {
    plot_data <- plot_data |>
      dplyr::mutate(
        panel_label = paste(
          as.character(.data$impulse),
          as.character(.data$response),
          sep = " \u2192 "
        ),
        panel_label = factor(
          .data$panel_label,
          levels = unique(.data$panel_label)
        )
      )
  }

  subtitle <- NULL

  if (resolved_layout == "grid") {
    subtitle <- "Columns: impulse | Rows: response"
  } else if (
    resolved_layout == "wrap" &&
    n_impulses > 1L &&
    n_responses > 1L
  ) {
    subtitle <- "Panels: impulse \u2192 response"
  } else if (n_impulses == 1L && n_responses > 1L) {
    subtitle <- paste0(
      "Impulse: ",
      as.character(unique(plot_data$impulse))
    )
  } else if (n_impulses > 1L && n_responses == 1L) {
    subtitle <- paste0(
      "Response: ",
      as.character(unique(plot_data$response))
    )
  } else {
    subtitle <- paste0(
      "Impulse: ",
      as.character(unique(plot_data$impulse)),
      " \u2192 Response: ",
      as.character(unique(plot_data$response))
    )
  }

  plot <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data$horizon, y = .data$estimate)
  )

  has_intervals <- any(
    !is.na(plot_data$lower) &
      !is.na(plot_data$upper)
  )

  if (ci && has_intervals) {
    plot <- plot +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
        alpha = 0.15
      )
  }

  plot <- plot +
    ggplot2::geom_hline(
      yintercept = 0,
      linewidth = 0.5,
      linetype = "dashed"
    ) +
    ggplot2::geom_line(linewidth = 0.7)

  if (resolved_layout == "grid") {
    plot <- plot +
      ggplot2::facet_grid(
        rows = ggplot2::vars(.data$response),
        cols = ggplot2::vars(.data$impulse),
        scales = scales
      )
  } else if (resolved_layout == "wrap") {
    if (n_impulses == 1L) {
      plot <- plot +
        ggplot2::facet_wrap(
          ggplot2::vars(.data$response),
          scales = scales
        )
    } else if (n_responses == 1L) {
      plot <- plot +
        ggplot2::facet_wrap(
          ggplot2::vars(.data$impulse),
          scales = scales
        )
    } else {
      plot <- plot +
        ggplot2::facet_wrap(
          ggplot2::vars(.data$panel_label),
          scales = scales
        )
    }
  }

  plot +
    ggplot2::labs(
      title = "Impulse response functions",
      subtitle = subtitle,
      x = "Horizon",
      y = "Response"
    )
}

#' Autoplot FEVD results
#'
#' @param object A `tv_fevd` object.
#' @param .response Optional response variables to display.
#' @param .shock Optional shocks to display.
#' @param ... Additional arguments reserved for future use.
#'
#' @return A `ggplot` object.
#'
#' @importFrom ggplot2 autoplot
#' @export
autoplot.tv_fevd <- function(
    object,
    .response = NULL,
    .shock = NULL,
    ...
) {
  rlang::check_dots_empty()

  available_responses <- unique(object$response)
  available_shocks <- unique(object$shock)

  if (!is.null(.response)) {
    if (length(.response) == 0L) {
      cli::cli_abort("{.arg .response} must contain at least one value.")
    }

    unknown_responses <- setdiff(.response, available_responses)

    if (length(unknown_responses) > 0L) {
      noun <- if (length(unknown_responses) == 1L) "value" else "values"

      cli::cli_abort(
        c(
          "Unknown {.arg .response} {noun}.",
          "x" = "Unknown: {.val {unknown_responses}}.",
          "i" = "Available: {.val {available_responses}}."
        )
      )
    }
  }

  if (!is.null(.shock)) {
    if (length(.shock) == 0L) {
      cli::cli_abort("{.arg .shock} must contain at least one value.")
    }

    unknown_shocks <- setdiff(.shock, available_shocks)

    if (length(unknown_shocks) > 0L) {
      noun <- if (length(unknown_shocks) == 1L) "value" else "values"

      cli::cli_abort(
        c(
          "Unknown {.arg .shock} {noun}.",
          "x" = "Unknown: {.val {unknown_shocks}}.",
          "i" = "Available: {.val {available_shocks}}."
        )
      )
    }
  }

  plot_data <- object

  if (!is.null(.response)) {
    plot_data <- plot_data |>
      dplyr::filter(.data$response %in% .env$.response)
  }

  if (!is.null(.shock)) {
    plot_data <- plot_data |>
      dplyr::filter(.data$shock %in% .env$.shock)
  }

  plot_data <- plot_data |>
    dplyr::mutate(
      response = factor(.data$response, levels = available_responses),
      shock = factor(.data$shock, levels = available_shocks)
    )

  n_responses <- dplyr::n_distinct(plot_data$response)

  if (n_responses == 1L) {
    subtitle <- paste0(
      "Response: ",
      as.character(unique(plot_data$response))
    )
  } else {
    subtitle <- "Panels: response"
  }

  plot <- plot <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data$horizon,
      y = .data$contribution,
      fill = .data$shock
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_y_continuous(
      labels = scales::label_percent()
    ) +
    ggplot2::coord_cartesian(
      ylim = c(0, 1)
    )

  if (n_responses > 1L) {
    plot <- plot +
      ggplot2::facet_wrap(
        ggplot2::vars(.data$response)
      )
  }

  plot +
    ggplot2::labs(
      title = "Forecast error variance decomposition",
      subtitle = subtitle,
      x = "Horizon",
      y = "Contribution",
      fill = "Shock"
    )
}

#' Autoplot forecast results
#'
#' @param object A `tv_predict` object.
#' @param .variable Optional variables to display.
#' @param n_history Number of historical observations to display. If `NULL`,
#'   all available history is shown. Forecast observations are never removed.
#' @param levels Optional confidence levels to display. If `NULL`, all
#'   confidence levels available in `object` are shown.
#' @param scales Scale behaviour across facets. One of `"free_y"` or
#'   `"fixed"`.
#' @param ci Whether to display forecast intervals when available.
#' @param ... Additional arguments reserved for future use.
#'
#' @return A `ggplot` object.
#'
#' @importFrom ggplot2 autoplot
#' @export
autoplot.tv_predict <- function(
    object,
    .variable = NULL,
    n_history = NULL,
    levels = NULL,
    scales = c("free_y", "fixed"),
    ci = TRUE,
    ...
) {
  rlang::check_dots_empty()

  scales <- rlang::arg_match(
    scales,
    c("free_y", "fixed")
  )

  if (!rlang::is_bool(ci)) {
    cli::cli_abort(
      "{.arg ci} must be `TRUE` or `FALSE`."
    )
  }

  if (
    !is.null(n_history) &&
    (
      !rlang::is_integerish(n_history, n = 1L) ||
      n_history < 1L
    )
  ) {
    cli::cli_abort(
      "{.arg n_history} must be a positive integer or `NULL`."
    )
  }

  if (!is.null(n_history)) {
    n_history <- as.integer(n_history)
  }

  available_variables <- unique(object$variable)

  available_levels <- object |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::pull(.data$level) |>
    unique()

  if (!is.null(.variable)) {
    if (length(.variable) == 0L) {
      cli::cli_abort(
        "{.arg .variable} must contain at least one value."
      )
    }

    unknown_variables <- setdiff(
      .variable,
      available_variables
    )

    if (length(unknown_variables) > 0L) {
      noun <- if (length(unknown_variables) == 1L) {
        "value"
      } else {
        "values"
      }

      cli::cli_abort(
        c(
          "Unknown {.arg .variable} {noun}.",
          "x" = "Unknown: {.val {unknown_variables}}.",
          "i" = "Available: {.val {available_variables}}."
        )
      )
    }
  }

  if (!is.null(levels)) {
    valid_levels <- is.numeric(levels) &&
      length(levels) >= 1L &&
      !anyNA(levels) &&
      all(is.finite(levels))

    if (!valid_levels) {
      cli::cli_abort(
        "{.arg levels} must contain one or more finite numeric values."
      )
    }

    unknown_levels <- setdiff(
      levels,
      available_levels
    )

    if (length(unknown_levels) > 0L) {
      cli::cli_abort(
        c(
          "Unknown {.arg levels}.",
          "x" = "Unavailable: {.val {unknown_levels}}.",
          "i" = "Available: {.val {available_levels}}."
        )
      )
    }
  } else {
    levels <- available_levels
  }

  plot_data <- object

  if (!is.null(.variable)) {
    plot_data <- plot_data |>
      dplyr::filter(
        .data$variable %in% .env$.variable
      )
  }

  plot_data <- plot_data |>
    dplyr::mutate(
      variable = factor(
        .data$variable,
        levels = available_variables
      )
    )

  history_data <- plot_data |>
    dplyr::filter(.data$type == "history")

  if (!is.null(n_history)) {
    history_data <- history_data |>
      dplyr::group_by(.data$variable) |>
      dplyr::slice_tail(n = n_history) |>
      dplyr::ungroup()
  }

  forecast_data <- plot_data |>
    dplyr::filter(
      .data$type == "forecast",
      .data$level %in% .env$levels
    )

  forecast_line_data <- forecast_data |>
    dplyr::distinct(
      .data$index,
      .data$variable,
      .data$estimate
    )

  interval_levels <- sort(
    unique(forecast_data$level),
    decreasing = TRUE
  )

  interval_labels <- scales::label_percent(
    accuracy = 1
  )(interval_levels)

  interval_alpha <- seq(
    from = 0.12,
    to = 0.30,
    length.out = length(interval_levels)
  )

  interval_data <- forecast_data |>
    dplyr::mutate(
      interval_level = factor(
        .data$level,
        levels = interval_levels,
        labels = interval_labels
      )
    ) |>
    dplyr::arrange(
      .data$variable,
      .data$interval_level,
      .data$index
    )

  combined_data <- dplyr::bind_rows(
    history_data,
    forecast_data
  )

  n_variables <- dplyr::n_distinct(
    combined_data$variable
  )

  has_intervals <- any(
    !is.na(interval_data$lower) &
      !is.na(interval_data$upper)
  )

  if (n_variables == 1L) {
    subtitle <- paste0(
      "Variable: ",
      as.character(unique(combined_data$variable))
    )
  } else {
    subtitle <- "Panels: variable"
  }

  plot <- ggplot2::ggplot(
    combined_data,
    ggplot2::aes(x = .data$index)
  )

  if (ci && has_intervals) {
    plot <- plot +
      ggplot2::geom_ribbon(
        data = interval_data,
        ggplot2::aes(
          ymin = .data$lower,
          ymax = .data$upper,
          group = .data$interval_level,
          alpha = .data$interval_level
        )
      ) +
      ggplot2::scale_alpha_manual(
        values = stats::setNames(
          interval_alpha,
          interval_labels
        ),
        name = "Confidence level",
        drop = FALSE
      )
  }

  plot <- plot +
    ggplot2::geom_line(
      data = history_data,
      ggplot2::aes(y = .data$observed),
      linewidth = 0.7
    ) +
    ggplot2::geom_line(
      data = forecast_line_data,
      ggplot2::aes(y = .data$estimate),
      linewidth = 0.7,
      linetype = "dashed"
    )

  if (n_variables > 1L) {
    plot <- plot +
      ggplot2::facet_wrap(
        ggplot2::vars(.data$variable),
        scales = scales
      )
  }

  plot +
    ggplot2::labs(
      title = "Forecasts",
      subtitle = subtitle,
      x = NULL,
      y = NULL
    )
}
