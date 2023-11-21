#' Tidy IRF for a VAR Model
#'
#' Tidyier for the `varest` class.
#'
#' @param x An object of the `varest` class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_causality(model)
tv_causality <- function(x, ...) UseMethod("tv_causality", x)

#' @rdname tv_causality
#' @export
tv_causality.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_causality` method for objects of class", class(x), "."))
}

#' @rdname tv_causality
#' @export
tv_causality.varest <- function(x, ...) {

  nms <- names(x$varresult)
  n   <- length(nms)

  .out <- tibble::tibble(.asset = names(x$varresult), .model = list(x)) |>
    dplyr::mutate(.causality = purrr::map2(.x = .model, .y = .asset, .f = ~ vars::causality(x = .x, cause = .y))) |>
    tidyr::unnest(cols = .causality) |>
    dplyr::mutate(.test      = rep(c("granger", "instant"), n),
                  .statistic = purrr::map_dbl(.x = .causality, "statistic"),
                  .parameter = purrr::map(.x = .causality, "parameter") |> purrr::map_dbl(dplyr::first),
                  .p.value   = purrr::map_dbl(.x = .causality, "p.value"),
                  .method    = purrr::map_chr(.x = .causality, "method")) |>
    dplyr::select(-c(.model:.causality)) |>
    dplyr::mutate(.asset = forcats::fct_reorder(forcats::as_factor(.asset), .p.value)) |>
    dplyr::arrange(.test)

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_causality")

}



