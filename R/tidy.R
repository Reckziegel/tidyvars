#' Tidy a VAR Model
#'
#' Tidier for the \code{varest} class.
#'
#' @param x An object of the \code{varest} class.
#' @param ... Additional objects to be pass through.
#'
#' @return A \code{tibble}.
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#'
#' tv_tidy(model)
tv_tidy <- function(x, ...) UseMethod("tv_tidy", x)

#' @rdname tv_tidy
#' @export
tv_tidy.default <- function(x, ...) {
  rlang::abort(message = paste0("No `tv_tidy` method for objects of class", class(x), "."))
}

#' @rdname tv_tidy
#' @export
tv_tidy.varest <- function(x, ...) {

  .summary <- summary(x)
  .n_coefs <- NROW(.summary$varresult[[1]]$coefficients)

  .out <- .summary$varresult |>
    purrr::map("coefficients")  |>
    purrr::map(as.data.frame) |>
    purrr::map(tibble::rownames_to_column) |>
    dplyr::bind_rows() |>
    tibble::as_tibble()

  .out <- .out |>
    dplyr::mutate(group     = rep(x = .summary$names, each = .n_coefs),
                  term      = rowname,
                  estimate  = Estimate,
                  std.error = `Std. Error`,
                  statistic = `t value`,
                  p.value   = `Pr(>|t|)`,
                  .keep     = "none"
    ) |>
    dplyr::mutate(term = forcats::fct_reorder(forcats::as_factor(term), statistic))

  tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_tidy")

}

# @rdname tv_tidy
# @export
# tv_tidy.vec2var <- function(x, ...) {
#
#   .summary <- summary(x)
#   .n_coefs <- NROW(.summary$varresult[[1]]$coefficients)
#
#   .out <- .summary$varresult |>
#     purrr::map("coefficients")  |>
#     purrr::map(as.data.frame) |>
#     purrr::map(tibble::rownames_to_column) |>
#     dplyr::bind_rows() |>
#     tibble::as_tibble()
#
#   .out <- .out |>
#     dplyr::mutate(group     = rep(x = .summary$names, each = .n_coefs),
#                   term      = rowname,
#                   estimate  = Estimate,
#                   sdt.error = `Std. Error`,
#                   statistic = `t value`,
#                   p.value   = `Pr(>|t|)`,
#                   .keep     = "none"
#     ) |>
#     dplyr::mutate(term = forcats::fct_reorder(forcats::as_factor(term), statistic))
#
#   tibble::new_tibble(x = .out, nrow = NROW(.out), class = "tv_tidy")
#
# }


# @importFrom generics tidy
# @export
#generics::tidy
