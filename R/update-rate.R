#' Update the rate limit of an existing rate limited function
#'
#' \code{UPDATE_RATE} modifies an existing rate-limited function in place,
#' changing the rate limits without otherwise altering the function's behavior.
#' When a rate limited function has its rate limits updated, the previous rate
#' limits and any calls that would have counted against those rate limits are
#' immediately forgotten, and only the new rate limits are obeyed going forward.
#'
#' @param lf A rate-limited function or group of functions
#' @param ... One or more rates, created using \code{\link{rate}}
#' @param precision The precision with which time intervals can be measured, in hertz
#'
#' @examples
#' f <- function() NULL
#' f_lim <- limit_rate(f, rate(n = 1, period = .1))
#'
#' # update the rate limits to 2 calls per .1 second
#' UPDATE_RATE(f_lim, rate(n = 2, period = .1))
#'
#' @export
UPDATE_RATE <- function(lf, ..., precision = 60) {
    gatekeeper_env <- parent.env(environment(lf))

    rates <- list(...)
    check_rates(rates)

    gatekeepers <- lapply(rates, function(rate)
        token_dispenser(
            n = rate[["n"]],
            period = rate[["period"]],
            precision = precision)
    )

    assign("gatekeepers", gatekeepers, pos = gatekeeper_env)
    invisible()
}
