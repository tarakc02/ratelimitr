#' Re-create a rate-limited function
#'
#' This function does not modify the original rate-limited function, instead
#' it returns a new function with the same rate limits (but no memory of prior
#' function calls).
#'
#' @param f A rate-limited function or group of functions
#'
#' @examples
#' f <- function() NULL
#' f_lim <- limit_rate(f, rate(n = 1, period = .1))
#' f_lim() ## the next call to f_lim will trigger the rate limit
#'
#' f_lim2 <- reset(f_lim) ## but f_lim2 has a fresh start
#'
#' ## f_lim2 behaves as though no calls have been made
#' system.time(f_lim2())
#'
#' ## while f_lim is still constrained
#' system.time(f_lim())
#'
#' @name reset
#' @export
reset <- function(f) UseMethod("reset")

#' @export
reset.rate_limited_function <- function(f) {
    func <- get_function(f)
    rates <- get_rates(f)
    precision <- get_precision(f)
    lim <- function(...) {
        limit_rate(func, ..., precision = precision)
    }
    do.call("lim", rates)
}

#' @export
reset.limited_function_list <- function(f) {
    funcs <- lapply(
        f,
        get_function
    )
    names(funcs) <- names(f)
    rates <- get_rates(f)
    precision <- get_precision(f)
    lim <- function(...) {
        limit_rate(funcs, ..., precision = precision)
    }

    do.call("lim", rates)
}
