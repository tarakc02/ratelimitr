#' @import assertthat
#' @export
rate <- function(n, period) {
    assert_that(is.number(n))
    assert_that(is.number(period))
    structure(c(
        n = n,
        period = period
    ), class = c("rate_limit", "numeric"))
}
