#' Create a new token dispenser
#'
#' A token dispenser is an object with one method, \code{\link{request}}, which
#' always returns TRUE, possibly after a delay. This function initializes a
#' token dispenser with the given parameters. A token dispenser will never
#' disburse more than \code{n} tokens in any window of length \code{period}.
#'
#' @param n Number of tokens disbursed in the given time period
#' @param period Length of period in seconds
#'
#' @import assertthat
#' @export
token_dispenser <- function(n, period) {
    assert_that(is.number(n))
    assert_that(is.number(period))

    init_time <- as.numeric(Sys.time())

    tokens <- new(queue)
    replicate(n, tokens$push(init_time))

    request <- function() {
        now <- as.numeric(Sys.time())
        if (tokens$size() != n)
            stop("Unexpected error")
        token <- tokens$front()
        if (now >= token) {
            tokens$pop()
            tokens$push(now + period)
            return(TRUE)
        }

        time_to_wait <- token - now
        Sys.sleep(time_to_wait)
        request()
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
request <- function(x) UseMethod("request")

#' @export
#' @rdname request
request.token_dispenser <- function(x) x()
