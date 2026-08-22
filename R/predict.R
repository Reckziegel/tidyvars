#' Tidy VAR forecasts
#'
#' Converts forecasts from a `varest` model into a tidy, self-contained
#' representation containing both the observed history and future forecasts.
#'
#' Historical observations are represented once for each variable and index.
#' Forecast observations are represented once for each variable, index, and
#' confidence level.
#'
#' @param x A `varest` object.
#' @param n_ahead A positive whole number giving the number of forecast
#'   periods.
#' @param level One or more confidence levels between 0 and 1.
#' @param ... Additional arguments passed to [stats::predict()], such as
#'   `dumvar`. The `ci` argument should not be supplied directly; use
#'   `level` instead.
#'
#' @return A `tv_predict` tibble with columns:
#'   `index`, `variable`, `type`, `level`, `observed`, `estimate`, `lower`,
#'   and `upper`.
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_predict(model, n_ahead = 12)
#' tv_predict(model, n_ahead = 12, level = 0.80)
#' tv_predict(model, n_ahead = 12, level = c(0.50, 0.75, 0.90))
tv_predict <- function(x, n_ahead, level = 0.95, ...) {
  if (missing(n_ahead)) {
    cli::cli_abort(
      c(
        "{.arg n_ahead} is required.",
        "i" = "Supply the forecast horizon, for example {.code n_ahead = 12}."
      )
    )
  }

  UseMethod("tv_predict", x)
}

#' @rdname tv_predict
#' @export
tv_predict.default <- function(x, n_ahead, level = 0.95, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_predict} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_predict
#' @export
tv_predict.varest <- function(x, n_ahead, level = 0.95, ...) {
  tidy_predict_impl(
    x,
    n_ahead = n_ahead,
    level = level,
    ...
  )
}

check_n_ahead <- function(n_ahead) {
  valid <- is.numeric(n_ahead) &&
    length(n_ahead) == 1L &&
    !is.na(n_ahead) &&
    is.finite(n_ahead) &&
    n_ahead >= 1 &&
    n_ahead == floor(n_ahead)

  if (!valid) {
    cli::cli_abort(
      "{.arg n_ahead} must be a positive whole number."
    )
  }

  as.integer(n_ahead)
}

check_prediction_level <- function(level) {
  valid <- is.numeric(level) &&
    length(level) >= 1L &&
    !anyNA(level) &&
    all(is.finite(level))

  if (!valid) {
    cli::cli_abort(
      "{.arg level} must contain one or more finite numeric values."
    )
  }

  if (any(level <= 0 | level >= 1)) {
    cli::cli_abort(
      "{.arg level} values must be greater than 0 and less than 1."
    )
  }

  if (anyDuplicated(level)) {
    cli::cli_abort(
      "{.arg level} must not contain duplicate values."
    )
  }

  as.double(level)
}

series_index <- function(x) {
  if (!is.null(stats::tsp(x))) {
    return(as.numeric(stats::time(x)))
  }

  row_names <- rownames(x)

  if (is.null(row_names)) {
    return(seq_len(NROW(x)))
  }

  is_iso_date <- grepl(
    "^\\d{4}-\\d{2}-\\d{2}$",
    row_names
  )

  if (all(is_iso_date)) {
    date_index <- as.Date(row_names)

    if (!anyNA(date_index)) {
      return(date_index)
    }
  }

  numeric_index <- suppressWarnings(as.numeric(row_names))

  if (all(is.finite(numeric_index))) {
    return(numeric_index)
  }

  row_names
}

date_index_spec <- function(index) {
  if (length(index) < 2L) {
    return(NULL)
  }

  day_gaps <- as.integer(diff(index))

  if (all(day_gaps == 1L)) {
    return(list(unit = "day", step = 1L))
  }

  if (all(day_gaps == 7L)) {
    return(list(unit = "day", step = 7L))
  }

  month_id <- 12L * lubridate::year(index) +
    lubridate::month(index)

  month_gaps <- diff(month_id)

  if (length(unique(month_gaps)) != 1L) {
    return(NULL)
  }

  month_step <- month_gaps[[1]]

  if (!month_step %in% c(1L, 3L, 12L)) {
    return(NULL)
  }

  day_of_month <- lubridate::mday(index)

  month_end <- index ==
    lubridate::ceiling_date(index, unit = "month") -
    lubridate::days(1)

  same_day <- length(unique(day_of_month)) == 1L

  if (!same_day && !all(month_end)) {
    return(NULL)
  }

  list(
    unit = "month",
    step = month_step,
    month_end = all(month_end)
  )
}

forecast_index <- function(index, n_ahead, source = NULL) {
  if (length(index) < 2L) {
    cli::cli_abort(
      "At least two historical observations are required to extend {.arg index}."
    )
  }

  if (!is.null(stats::tsp(source))) {
    step <- stats::deltat(source)

    return(
      utils::tail(index, 1L) +
        step * seq_len(n_ahead)
    )
  }

  if (inherits(index, "Date")) {
    spec <- date_index_spec(index)

    if (is.null(spec)) {
      cli::cli_abort(
        paste0(
          "Cannot infer a regular future index from the historical dates. ",
          "Use a regular daily, weekly, monthly, quarterly, or yearly index."
        )
      )
    }

    if (identical(spec$unit, "day")) {
      return(
        utils::tail(index, 1L) +
          spec$step * seq_len(n_ahead)
      )
    }

    future <- lubridate::add_with_rollback(
      utils::tail(index, 1L),
      lubridate::period(
        months = spec$step * seq_len(n_ahead)
      )
    )

    if (spec$month_end) {
      future <- lubridate::ceiling_date(
        future,
        unit = "month"
      ) - lubridate::days(1)
    }

    return(as.Date(future))
  }

  if (is.numeric(index)) {
    steps <- diff(index)
    step <- steps[[1]]
    tolerance <- sqrt(.Machine$double.eps) * max(1, abs(step))

    is_regular <- step > 0 &&
      all(abs(steps - step) <= tolerance)

    if (!is_regular) {
      cli::cli_abort(
        "Cannot infer a regular future index from the historical numeric index."
      )
    }

    return(
      utils::tail(index, 1L) +
        step * seq_len(n_ahead)
    )
  }

  cli::cli_abort(
    paste0(
      "Cannot extend a character index safely. ",
      "Use a `ts` index, regular numeric index, or supported date row names."
    )
  )
}

tidy_forecast_level <- function(
    prediction,
    level,
    future_index
) {
  purrr::imap_dfr(
    prediction$fcst,
    function(values, variable) {
      values <- as.matrix(values)
      column_names <- colnames(values)

      if (!"fcst" %in% column_names) {
        cli::cli_abort(
          "Unexpected forecast structure returned by {.fn stats::predict}."
        )
      }

      if (nrow(values) != length(future_index)) {
        cli::cli_abort(
          "Forecast rows do not match the requested forecast horizon."
        )
      }

      lower <- if ("lower" %in% column_names) {
        as.double(values[, "lower"])
      } else {
        rep(NA_real_, nrow(values))
      }

      upper <- if ("upper" %in% column_names) {
        as.double(values[, "upper"])
      } else {
        rep(NA_real_, nrow(values))
      }

      tibble::tibble(
        index = future_index,
        variable = as.character(variable),
        type = "forecast",
        level = level,
        observed = NA_real_,
        estimate = as.double(values[, "fcst"]),
        lower = lower,
        upper = upper
      )
    }
  )
}

tidy_predict_impl <- function(
    x,
    n_ahead,
    level = 0.95,
    ...
) {
  n_ahead <- check_n_ahead(n_ahead)
  level <- check_prediction_level(level)

  dots <- rlang::list2(...)

  if ("ci" %in% names(dots)) {
    cli::cli_abort(
      c(
        "{.arg ci} is not an argument of {.fn tv_predict}.",
        "i" = "Use {.arg level} to set forecast confidence levels."
      )
    )
  }

  predictions <- purrr::map(
    level,
    function(current_level) {
      rlang::exec(
        stats::predict,
        x,
        n.ahead = n_ahead,
        ci = current_level,
        !!!dots
      )
    }
  )

  first_prediction <- predictions[[1]]

  history_data <- first_prediction$endog
  history_index <- series_index(history_data)

  future_index <- forecast_index(
    history_index,
    n_ahead = n_ahead,
    source = history_data
  )

  variables <- names(first_prediction$fcst)

  same_variables <- purrr::every(
    predictions,
    ~ identical(names(.x$fcst), variables)
  )

  if (!same_variables) {
    cli::cli_abort(
      "Forecast variables changed across confidence levels."
    )
  }

  history <- history_data |>
    tibble::as_tibble(.name_repair = "minimal") |>
    dplyr::mutate(index = history_index) |>
    tidyr::pivot_longer(
      cols = -dplyr::all_of("index"),
      names_to = "variable",
      values_to = "observed"
    ) |>
    dplyr::transmute(
      index = .data$index,
      variable = as.character(.data$variable),
      type = "history",
      level = NA_real_,
      observed = as.double(.data$observed),
      estimate = NA_real_,
      lower = NA_real_,
      upper = NA_real_
    )

  forecast <- purrr::map2_dfr(
    predictions,
    level,
    ~ tidy_forecast_level(
      prediction = .x,
      level = .y,
      future_index = future_index
    )
  )

  out <- dplyr::bind_rows(
    history,
    forecast
  )

  variable_order <- match(out$variable, variables)
  level_order <- match(out$level, level)

  row_order <- order(
    out$index,
    variable_order,
    level_order,
    na.last = TRUE
  )

  out <- out[row_order, , drop = FALSE]

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_predict"
  )
}
