#' Tidy Residuals Test
#'
#' Tidier for the \code{varest} and \code{vec2var} class.
#'
#' @param x An object of the \code{varest} and \code{vec2var} class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_serial_test(model)
tv_serial_test <- function(x, ...) UseMethod("tv_serial_test", x)

#' @rdname tv_serial_test
#' @export
tv_serial_test.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_serial_test` method for objects of class", class(x), "."))
}

#' @rdname tv_serial_test
#' @export
tv_serial_test.varest <- function(x, ...) {

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


#' @rdname tv_serial_test
#' @export
tv_serial_test.vec2var <- function(x, ...) {

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
