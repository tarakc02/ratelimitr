#' Create a new token dispenser
#'
#' A token dispenser is an object with one method, \code{\link{request}}, which
#' always returns TRUE, possibly after a delay. This function initializes a
#' token dispenser with the given parameters. A token dispenser will never
#' disburse more than \code{n} tokens in any window of length \code{period}.
#'
#' @param n Number of tokens disbursed in the given time period
#' @param period Length of period in seconds
#' @param precision Resolution with which to measure time, in fractions of a second
#'
#' @details
#' In order to guarantee compliance with a rate limit, the token dispenser
#' by default measures time intervals to the 1/60th of a second, always rounding
#' down. Use the \code{precision} argument to specify what fraction of a second
#' to use (60 means 1/60th, 100 means 1/100, etc).
#'
#' @import assertthat
#' @export
token_dispenser <- function(n, period, precision = 60) {
    assert_that(is.number(n))
    assert_that(is.number(period))

    # times should be in increments of (1 / precision) of seconds
    # So period (entered in seconds) is converted to period * precision
    period <- period * precision

    init_time <- ceiling(as.numeric(Sys.time()) * precision)

    tokens <- new(queue)
    replicate(n, tokens$push(init_time))

    request <- function() {
        if (tokens$size() != n)
            stop("Unexpected error")
        now <- floor(as.numeric(Sys.time()) * precision)
        token <- tokens$front()
        if (now >= token) {
            tokens$pop()
            tokens$push(now + 1 + period)
            return(TRUE)
        }

        # wait time should be converted back to whole seconds
        time_to_wait <- (token - now) / precision
        signalCondition(rate_limit_exception(time_to_wait))
    }
    structure(request, class = "token_dispenser")
}

#' Request a token from a token dispenser
#'
#' Once you've created a \code{\link{token_dispenser}}, use this function to
#' request tokens. Tokens will be disbursed subject to the rate limit implied
#' by the \code{token_dispenser}.
#'
#' @param x A \code{\link{token_dispenser}}
#'
#' @return TRUE (possibly after a delay)
#' @export
request <- function(x, policy = wait) UseMethod("request")

#' @export
#' @rdname request
request.token_dispenser <- function(x, policy = wait) {
    tryCatch(
        x(),
        rate_limit_exception = function(e) policy(x, e),
        error = function(e) stop(e$message, call. = FALSE)
    )
}
