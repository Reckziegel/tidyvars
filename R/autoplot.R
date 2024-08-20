#' Autoplot Methods for VAR Models
#'
#' \code{autoplot()} uses ggplot2 to draw a plots for objects created with \code{tv_*()}
#' functions in a single command.
#'
#' @param object An object, whose class will determine the behavior of autoplot.
#' @param .impulse A \code{character}. The variable to be used as impulse.
#' Defaults to \code{NULL}.
#' @param .response A \code{character}. The variable to be used as response.
#' @param .n_obs A \code{double}. The number of observations to be included in
#' the plot.
#' @param ... Other arguments passed to specific methods.
#'
#' @return A \code{ggplot2} object.
#' @export
#'
#' @rdname autoplot
#' @importFrom ggplot2 autoplot
#'
#' @examples
#' library(ggplot2)
#'
#' model <- vars::VAR(EuStockMarkets)
#'
#' autoplot(tv_fevd(model))
#' autoplot(tv_irf(model))
autoplot.tv_fevd <- function(object, .impulse = NULL, .response = NULL, ...) {

  if (!is.null(.impulse)) {
    object <- dplyr::filter(object, .impulse %in% {{.impulse}})
  }

  if (!is.null(.response)) {
    object <- dplyr::filter(object, .asset %in% {{.response}})
  }

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .fevd, fill = .asset)) +
    ggplot2::geom_col(position = "fill") +
    ggplot2::facet_wrap(~.impact, scales = "free_y") +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    ggplot2::labs(title    = "Forecast Error Variance Decomposition",
                  subtitle = "FEVD functions for shock in variables",
                  x = "Periods Ahead",
                  y = "FEVD",
                  fill = NULL) #+
    #ggplot2::theme(legend.position = "bottom")

}

#' @rdname autoplot
#' @export
autoplot.tv_irf <- function(object, .impulse = NULL, .response = NULL, ...) {

  if (!is.null(.impulse)) {
    object <- dplyr::filter(object, .impulse %in% {{.impulse}})
  }

  if (!is.null(.response)) {
    object <- dplyr::filter(object, .asset %in% {{.response}})
  }

  object |>
    dplyr::mutate(label = paste0(.impulse, " -> ", .asset)) |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .irf, color = .impulse, fill = .impulse)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .lower, ymax = .upper), alpha = 0.1, linetype = 3) +
    ggplot2::geom_line() +
    ggplot2::geom_hline(yintercept = 0, color = "grey", linetype = 1, linewidth = 1) +
    ggplot2::facet_wrap(facets = . ~ label, scales = "free_y") +
    ggplot2::labs(title    = "Impulse-Response Functions",
                  subtitle = "Impulse -> Response",
                  x        = "Periods Ahead",
                  y        = "Impulse-Responses"
    ) +
    ggplot2::theme(legend.position = "NULL")

}

# @rdname autoplot
# @export
# autoplot.tv_predict <- function(object, ...) {
#
#   object |>
#     ggplot2::ggplot(ggplot2::aes(x = rowid, y = fcst, color = .asset, fill = .asset)) +
#     ggplot2::geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.25) +
#     ggplot2::geom_line() +
#     #ggplot2::geom_line(ggplot2::aes(y = lower), linetype = 2) +
#     #ggplot2::geom_line(aes(y = upper), linetype = 2) +
#     ggplot2::facet_wrap(~ .asset, scales = "free_y") +
#     ggplot2::labs(color = "Asset")
#
# }

#' @rdname autoplot
#' @export
autoplot.tv_augment <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .x, color = .asset)) +
    ggplot2::geom_line(alpha = 0.25, show.legend = FALSE) +
    ggplot2::geom_line(ggplot2::aes(y = .fitted), show.legend = FALSE) +
    ggplot2::facet_wrap(~ .asset, scales = "free_y") +
    ggplot2::labs(color = NULL, x = NULL, y = NULL)

}

#' @rdname autoplot
#' @export
#' @param type The column that should be plotted.
autoplot.tv_tidy <- function(object, type = c("estimate", "statistic"), ...) {

  assertthat::assert_that(assertthat::is.string(type))
  rlang::arg_match(type, c("estimate", "statistic"))

  if (type == "estimate") {

    object |>
      ggplot2::ggplot(ggplot2::aes(x = term, y = estimate, fill = term)) +
      ggplot2::geom_col(show.legend = FALSE) +
      ggplot2::geom_hline(yintercept = 0, linetype = 1, color = "grey") +
      ggplot2::facet_wrap(~group, scales = "free_y")

  } else {

    object |>
      ggplot2::ggplot(ggplot2::aes(x = term, y = statistic, fill = term)) +
      ggplot2::geom_col(show.legend = FALSE) +
      ggplot2::geom_hline(yintercept = 2, linetype = 1, color = "grey", size = 1, show.legend = FALSE) +
      ggplot2::geom_hline(yintercept = -2, linetype = 1, color = "grey", size = 1, show.legend = FALSE) +
      ggplot2::facet_wrap(~group, scales = "free_y")

  }

}

#' @rdname autoplot
#' @export
autoplot.tv_causality <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = .asset, y = .p.value, fill = .test)) +
    ggplot2::geom_col() +
    ggplot2::geom_hline(yintercept = 0.05, color = "grey", size = 1) +
    ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    ggplot2::facet_wrap(~ .test)

}

#' @rdname autoplot
#' @export
autoplot.tv_predict <- function(object, .n_obs = NULL, ...) {

  .data <- tibble::as_tibble(attributes(object)$.data) |>
    tibble::rowid_to_column()

  maybe_date <- attributes(object)$date
  if (any(!is.na(maybe_date))) {
    .data <- dplyr::mutate(.data, rowid = maybe_date)
  }

  .data <- .data |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = ".x") |>
    dplyr::mutate(fcst = NA_real_, lower = NA_real_, upper = NA_real_, CI = NA_real_) |>
    dplyr::mutate(.asset = forcats::as_factor(.asset))


  .pred <- object |>
    dplyr::mutate(.x = NA_real_, .asset = forcats::as_factor(.asset)) |>
    dplyr::arrange(rowid)

  .out <- dplyr::bind_rows(.data, .pred)

  .unique <- length(unique(object$.asset))
  .n_data <- nrow(.data) / .unique
  .n_pred <- nrow(.pred) / .unique
  .vec <- rep(1:.n_data, each = .unique)
  .fcst_vec <- rep(max(.vec) + 1:.n_pred, each = .unique)

  # If does not contain dates...
  if (any(is.na(maybe_date))) {

    .pred <- dplyr::mutate(.pred, rowid  = rowid + .n_data)
    .out  <- dplyr::bind_rows(.data, .pred)


    .out <- .out |>
      dplyr::mutate(rowid = c(.vec, .fcst_vec))

  }

  # If the last obs should be filtered...
  if (!is.null(.n_obs)) {

    assertthat::assert_that(assertthat::is.number(.n_obs))
    .out <- dplyr::slice_tail(.out, n = .n_obs * .unique + length(.fcst_vec))

  }


  .out |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .x)) +
    ggplot2::geom_line(show.legend = FALSE) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lower, ymax = upper), alpha = 0.25) +
    ggplot2::geom_line(ggplot2::aes(x = rowid, y = fcst), linetype = 2, show.legend = FALSE) +
    ggplot2::facet_wrap(~ .asset, scales = "free_y") +
    ggplot2::labs(x = NULL, y = NULL)

}



#' @rdname autoplot
#' @importFrom graphics plot
plot.tv_causality <- function(object, ...) print(ggplot2::autoplot(object, ...))

#' @rdname autoplot
plot.tv_fevd <- function(object, ...) print(ggplot2::autoplot(object, ...))

#' @rdname autoplot
plot.tv_irf <- function(object, ...) print(ggplot2::autoplot(object, ...))

#' @rdname autoplot
plot.tv_predict <- function(object, ...) print(ggplot2::autoplot(object, ...))

#' @rdname autoplot
plot.tv_augment <- function(object, ...) print(ggplot2::autoplot(object, ...))

#' @rdname autoplot
plot.tv_tidy <- function(object, ...) print(ggplot2::autoplot(object, ...))

