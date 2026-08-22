# Printing helpers --------------------------------------------------------

print_tidyvars_header <- function(title, details = NULL) {

  cat("<tidyvars ", title, ">\n", sep = "")

  if (!is.null(details)) {
    cat(details, "\n", sep = "")
  }

}

format_count <- function(label, x) {
  paste0(label, ": ", dplyr::n_distinct(x))
}

format_horizon_range <- function(x) {
  range <- range(x, na.rm = TRUE)
  paste0("Horizons: ", range[[1]], "-", range[[2]])
}


# Print methods -----------------------------------------------------------

#' @export
print.tv_tidy <- function(x, ...) {
  details <- paste(
    format_count("Equations", x$equation),
    format_count("Terms", x$term),
    sep = " | "
  )
  print_tidyvars_header("coefficients", details)
  NextMethod()
}

#' @export
print.tv_glance <- function(x, ...) {
  details <- format_count("Equations", x$equation)
  print_tidyvars_header("equation summaries", details)
  NextMethod()
}

#' @export
print.tv_augment <- function(x, ...) {
  details <- paste(
    format_count("Variables", x$variable),
    format_count("Observations", x$index),
    sep = " | "
  )
  print_tidyvars_header("augmented data", details)
  NextMethod()
}

#' @export
print.tv_irf <- function(x, ...) {
  details <- paste(
    format_count("Impulses", x$impulse),
    format_count("Responses", x$response),
    format_horizon_range(x$horizon),
    sep = " | "
  )
  print_tidyvars_header("IRF", details)
  NextMethod()
}

#' @export
print.tv_fevd <- function(x, ...) {
  details <- paste(
    format_count("Responses", x$response),
    format_count("Shocks", x$shock),
    format_horizon_range(x$horizon),
    sep = " | "
  )
  print_tidyvars_header("FEVD", details)
  NextMethod()
}

#' @export
print.tv_predict <- function(x, ...) {

  history_periods <- x |>
    dplyr::filter(.data$type == "history") |>
    dplyr::pull(.data$index) |>
    dplyr::n_distinct()

  forecast_periods <- x |>
    dplyr::filter(.data$type == "forecast") |>
    dplyr::pull(.data$index) |>
    dplyr::n_distinct()

  details <- paste(
    format_count("Variables", x$variable),
    paste0("History: ", history_periods),
    paste0("Forecast: ", forecast_periods),
    sep = " | "
  )
  print_tidyvars_header("forecast", details)
  NextMethod()
}

#' @export
print.tv_causality <- function(x, ...) {
  details <- paste(
    format_count("Causes", x$cause),
    format_count("Tests", x$test),
    sep = " | "
  )
  print_tidyvars_header("causality tests", details)
  NextMethod()
}

#' @export
print.tv_normality_test <- function(x, ...) {
  details <- paste(
    format_count("Scopes", x$scope),
    format_count("Tests", x$test),
    sep = " | "
  )
  print_tidyvars_header("normality tests", details)
  NextMethod()
}

#' @export
print.tv_serial_test <- function(x, ...) {
  details <- format_count("Tests", x$test)
  print_tidyvars_header("serial tests", details)
  NextMethod()
}
