#' Autoplot Methods for VAR Models
#'
#' \code{autoplot()} uses ggplot2 to draw a particular plot for an object of a
#' particular class in a single command.
#'
#' @param object An object, whose class will determine the behavior of autoplot.
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
autoplot.tv_fevd <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .fevd, fill = .asset)) +
    ggplot2::geom_col(position = "fill") +
    ggplot2::facet_wrap(~.impact, scales = "free_y") +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    ggplot2::labs(title    = "Forecast Error Variance Decomposition",
                  subtitle = "FEVD functions for shock in variables",
                  x = "Periods Ahead",
                  y = "FEVD",
                  fill = "Variable") #+
    #ggplot2::theme(legend.position = "bottom")

}

#' @rdname autoplot
#' @export
autoplot.tv_irf <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .irf, color = .asset)) +
    ggplot2::geom_line() +
    ggplot2::geom_line(ggplot2::aes(y = .lower), linetype = 2) +
    ggplot2::geom_line(ggplot2::aes(y = .upper), linetype = 2) +
    ggplot2::geom_hline(yintercept = 0, color = "grey", linetype = 1, size = 1) +
    #ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 0.01)) +
    ggplot2::facet_wrap(.impulse ~ .asset, scales = "free_y") +
    ggplot2::labs(title    = "Impulse-Response Funcions",
                  subtitle = "Impulse (above) --> Response (bellow)",
                  x        = "Periods Ahead",
                  y        = "Impulse-Responses"
    ) +
    ggplot2::theme(legend.position = "NULL")

}

#' @rdname autoplot
#' @export
autoplot.tv_predict <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = fcst, color = .asset)) +
    ggplot2::geom_line() +
    ggplot2::geom_line(ggplot2::aes(y = lower), linetype = 2) +
    ggplot2::geom_line(aes(y = upper), linetype = 2) +
    ggplot2::facet_wrap(~ .asset, scales = "free_y") +
    ggplot2::labs(color = "Asset")

}

#' @rdname autoplot
#' @export
autoplot.tv_augment <- function(object, ...) {

  object |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .x, color = .asset)) +
    ggplot2::geom_line(alpha = 0.5) +
    ggplot2::geom_line(ggplot2::aes(y = .fitted)) +
    ggplot2::facet_wrap(~ .asset) +
    ggplot2::labs(color = "Asset")

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
      ggplot2::geom_col() +
      ggplot2::geom_hline(yintercept = 0, linetype = 1, color = "grey") +
      ggplot2::facet_wrap(~group, scales = "free_y")

  } else {

    object |>
      ggplot2::ggplot(ggplot2::aes(x = term, y = statistic, fill = term)) +
      ggplot2::geom_col() +
      ggplot2::geom_hline(yintercept = 2, linetype = 1, color = "grey", size = 1) +
      ggplot2::geom_hline(yintercept = -2, linetype = 1, color = "grey", size = 1) +
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
autoplot.tv_predict <- function(object, ...) {

  .data <- tibble::as_tibble(attributes(object)$.data) |>
    tibble::rowid_to_column() |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = ".y") |>
    dplyr::mutate(fcst = NA_real_, lower = NA_real_, upper = NA_real_, CI = NA_real_) |>
    dplyr::mutate(.asset = forcats::fct_reorder(forcats::as_factor(.asset), rowid))

  .pred <- object |>
    dplyr::mutate(.x = NA_real_) |>
    dplyr::mutate(.asset = forcats::fct_reorder(forcats::as_factor(.asset), rowid)) |>
    dplyr::arrange(rowid)

  .unique <- length(unique(object$.asset))
  .n_data <- nrow(.data) / .unique
  .n_pred <- nrow(.pred) / .unique

  .vec <- rep(1:.n_data, each = .unique)
  .fcst_vec <- rep(max(.vec) + 1:.n_pred, each = .unique)


  dplyr::bind_rows(.data, .pred) |>
    dplyr::mutate(rowid = c(.vec, .fcst_vec)) |>
    dplyr::slice_tail(n = if (.n_data > 300) 300 else .n_data) |>
    ggplot2::ggplot(ggplot2::aes(x = rowid, y = .y, color = .asset)) +
    ggplot2::geom_line() +
    ggplot2::geom_line(ggplot2::aes(x = rowid, y = fcst), linetype = 2) +
    ggplot2::geom_line(ggplot2::aes(x = rowid, y = lower), linetype = 3) +
    ggplot2::geom_line(ggplot2::aes(x = rowid, y = upper), linetype = 3) +
    ggplot2::facet_wrap(~ .asset, scales = "free_y") +
    ggplot2::labs(color = NULL)

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

