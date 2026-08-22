#' Glance at the equations of a VAR model
#'
#' Summarises each equation of a VAR model using the corresponding linear
#' model stored in the `varest` object.
#'
#' Each row represents one equation of the VAR. Model fit statistics such as
#' `log_lik`, `aic`, and `bic` refer to the individual equation, not to the
#' multivariate VAR system as a whole.
#'
#' @param x A `varest` object.
#' @param ... Additional arguments passed to [broom::glance()] for each
#'   equation.
#'
#' @return A tibble with one row per equation and columns:
#'   `equation`, `r_squared`, `adj_r_squared`, `sigma`, `statistic`,
#'   `p_value`, `df`, `log_lik`, `aic`, `bic`, `deviance`,
#'   `df_residual`, and `n_obs`.
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_glance(model)
tv_glance <- function(x, ...) {
  UseMethod("tv_glance", x)
}

#' @rdname tv_glance
#' @export
tv_glance.default <- function(x, ...) {
  class_name <- class(x)[[1]]
  cli::cli_abort(
    "No {.fn tv_glance} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_glance
#' @export
tv_glance.varest <- function(x, ...) {
  tidy_glance_impl(x, ...)
}

tidy_glance_impl <- function(x, ...) {

  out <- x$varresult |>
    purrr::map(broom::glance, ...) |>
    purrr::list_rbind(names_to = "equation") |>
    dplyr::transmute(
      equation      = as.character(.data$equation),
      r_squared     = .data$r.squared,
      adj_r_squared = .data$adj.r.squared,
      sigma         = .data$sigma,
      statistic     = .data$statistic,
      p_value       = .data$p.value,
      df            = .data$df,
      log_lik       = .data$logLik,
      aic           = .data$AIC,
      bic           = .data$BIC,
      deviance      = .data$deviance,
      df_residual   = .data$df.residual,
      n_obs         = .data$nobs
    )

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_glance"
  )
}
