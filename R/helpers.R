#' @keywords internal
map_irf <- function(x, values_to, ...) {

  x |>
    purrr::map(tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".impulse") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .impulse, dplyr::everything()) |>
    tidyr::pivot_longer(cols = -c("rowid", ".impulse"), names_to = ".asset", values_to = values_to)

}

#' @keywords internal
map_augment <- function(x, values_to, ...) {

  x |>
    tibble::as_tibble() |>
    tibble::rowid_to_column() |>
    tidyr::pivot_longer(cols = -rowid, names_to = ".asset", values_to = values_to)

}

#' @keywords internal
check_date_col <- function(x) {

  rn <- rownames(x$datamat)[[1]]

  if (!is.null(rn)) {
    rn |>
      stringr::str_split(pattern = "-") |>
      purrr::chuck(1) |>
      length()

  } else {

    1

  }

}

#' @keywords internal
tidy_impulses <- function(x, ...) {

  impulse <- vars::irf(x, ...)

  .irf   <- map_irf(impulse$irf, values_to = ".irf")
  .lower <- map_irf(impulse$Lower, values_to = ".lower")
  .upper <- map_irf(impulse$Upper, values_to = ".upper")

  .out <- purrr::reduce(
    .x = list(.irf, .lower, .upper),
    .f = dplyr::left_join,
    by = c("rowid", ".impulse", ".asset")
  )

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_irf")

}


#' @keywords internal
tidy_normality_test <- function(x, ...) {

  norm_test <- vars::normality.test(x, ...)

  .out <- tibble::enframe(norm_test$jb.mul, name = ".test") |>
    dplyr::mutate(
      .statistic = purrr::map_dbl(.x = value, .f = "statistic"),
      .parameter = purrr::map_dbl(.x = value, .f = "parameter"),
      .p.value   = purrr::map_dbl(.x = value, .f = "p.value"),
      .method    = purrr::map_chr(.x = value, .f = "method")
    ) |>
    dplyr::select(-value)

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_normality_test")

}

#' @keywords internal
tidy_serial_test <- function(x, ...) {

  tibble::tibble(.type = c("PT.asymptotic", "PT.adjusted", "BG", "ES"), .model = list(x)) |>
    dplyr::mutate(.test = purrr::map2(
      .x = .type,
      .y = .model,
      .f = \(.x, .y) vars::serial.test(x = .y, type = .x)) |> purrr::map("serial")
    ) |>
    dplyr::mutate(
      .statistic = purrr::map_dbl(.x = .test, .f = "statistic"),
      .parameter = purrr::map(.x = .test, .f = "parameter") |> purrr::map_dbl(dplyr::first),
      .p.value   = purrr::map_dbl(.x = .test, .f = "p.value"),
      .method    = purrr::map_chr(.x = .test, .f = "method")
    ) |>
    dplyr::select(-c(.model, .test)) |>
    dplyr::mutate(.type = forcats::fct_reorder(forcats::as_factor(.type), .p.value)) |>
    dplyr::rename(.test = .type)

}

#' @keywords internal
#' @importFrom lubridate %m+%
check_time_interval <- function(x, n.ahead, ...) {

  date_diff <- diff(x)

  # Determine frequency by logical checks
  if (all(date_diff == 1)) {
    period <- "daily"
    utils::tail(x, 1) %m+% lubridate::days(1:n.ahead)
  } else if (all(date_diff == 7)) {
    period <- "weekly"
    utils::tail(x, 1) %m+% lubridate::weeks(1:n.ahead)
  } else if (all(date_diff >= 28 & date_diff <= 31)) {
    period <- "monthly"
    utils::tail(x, 1) %m+% months(1:n.ahead)
  } else {
    period <- "iregular"
  }

}
