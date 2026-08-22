# R/tidy.R ----------------------------------------------------------------

#' Tidy VAR model coefficients
#'
#' Converts coefficient estimates from a supported VAR model into a tidy
#' tibble. Each row represents one estimated coefficient in one equation
#' of the VAR.
#'
#' @param x A supported VAR model object.
#' @param ... Additional arguments passed to methods.
#'
#' @return
#' A tibble with one row per coefficient-equation pair and the following
#' columns:
#' \describe{
#'   \item{equation}{Character. Equation of the VAR.}
#'   \item{term}{Character. Model term associated with the coefficient.}
#'   \item{estimate}{Double. Estimated coefficient.}
#'   \item{std_error}{Double. Standard error of the estimate.}
#'   \item{statistic}{Double. t statistic for the coefficient.}
#'   \item{p_value}{Double. p-value associated with the t statistic.}
#' }
#'
#' @details
#' `tv_tidy()` currently provides inferential coefficient statistics for
#' `varest` objects. The values are extracted from the coefficient tables
#' exposed by the corresponding \code{vars} model.
#'
#' The `equation` and `term` columns are returned as character vectors.
#' Their ordering and representation are not modified for plotting purposes.
#'
#' @export
#'
#' @examples
#' model <- vars::VAR(EuStockMarkets)
#' tv_tidy(model)
tv_tidy <- function(x, ...) {
  UseMethod("tv_tidy")
}

#' @rdname tv_tidy
#' @export
tv_tidy.default <- function(x, ...) {
  class_name <- class(x)[[1]]

  cli::cli_abort(
    "No {.fn tv_tidy} method for objects of class {.cls {class_name}}."
  )
}

#' @rdname tv_tidy
#' @export
tv_tidy.varest <- function(x, ...) {
  tidy_varest_coefficients(x)
}

#' @rdname tv_tidy
#' @export
tv_tidy.vec2var <- function(x, ...) {
  cli::cli_abort(c(
    "{.fn tv_tidy} does not currently support {.cls vec2var} objects.",
    "i" = paste(
      "{.pkg vars} does not expose coefficient standard errors,",
      "t statistics, and p-values for the transformed VAR in levels."
    )
  ))
}

#' Extract tidy coefficients from a varest object
#'
#' @param x A `varest` object.
#'
#' @return A `tv_tidy` tibble.
#' @keywords internal
tidy_varest_coefficients <- function(x) {

  out <- stats::coef(x) |>

    purrr::imap_dfr(

      \(coefficients, equation) {
        coefficients |>
          tibble::as_tibble(rownames = "term") |>
          dplyr::transmute(
            equation  = equation,
            term      = .data$term,
            estimate  = .data$Estimate,
            std_error = .data$`Std. Error`,
            statistic = .data$`t value`,
            p_value   = .data$`Pr(>|t|)`
          )
      }

    )

  tibble::new_tibble(
    out,
    nrow = nrow(out),
    class = "tv_tidy"
  )

}





