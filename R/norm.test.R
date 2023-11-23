#' Tidy Normality Test
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
#' tv_normality_test(model)
tv_normality_test <- function(x, ...) UseMethod("tv_normality_test", x)

#' @rdname tv_normality_test
#' @export
tv_normality_test.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_normality_test` method for objects of class", class(x), "."))
}

#' @rdname tv_normality_test
#' @export
tv_normality_test.varest <- function(x, ...) {

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

#' @rdname tv_normality_test
#' @export
tv_normality_test.vec2var <- function(x, ...) {

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
