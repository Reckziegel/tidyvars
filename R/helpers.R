#' @keywords internal
map_irf <- function(x, ...) {

  x |>
    purrr::map(tibble::as_tibble) |>
    purrr::map(tibble::rowid_to_column) |>
    tibble::enframe(name = ".impulse") |>
    tidyr::unnest(cols = value) |>
    dplyr::relocate(rowid, .impulse, dplyr::everything())

}

#' @keywords internal
map_augment <- function(x, ...) {

  tibble::as_tibble(x) |>
    tibble::rowid_to_column()

}

#' @keywords internal
check_date_col <- function(x) {

  rownames(x$datamat)[[1]] |>
    stringr::str_split(pattern = "-") |>
    purrr::chuck(1) |>
    length()

}
