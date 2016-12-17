#' Create a new rate
#'
#' @param n Number of allowed events within a period
#' @param period Length (in seconds) of measurement period
#'
#' @examples
#' ## a function
#' f <- function() NULL
#'
#' ## limit f to 10 calls per second
#' limited_f <- limit_rate(f, rate(n = 10, period = 1))
#'
#' @seealso \code{\link{limit_rate}}
#'
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
