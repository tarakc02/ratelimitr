#' Access the rate limit(s) of a rate limited function
#'
#' @param f A rate limited function or group of functions
#'
#' @export
get_rates <- function(f) UseMethod("get_rates")

#' Access the rate limit precision
#'
#' @param f A rate limited function or group of functions
#'
#' @export
get_precision <- function(f) UseMethod("get_precision")

#' Access the original function from a rate limited function
#'
#' @param f A rate limited function or group of functions
#'
#' @export
get_function <- function(f) UseMethod("get_function")

#' @export
get_rates.rate_limited_function <- function(f) {
    info <- attr(f, "info")()
    lapply(info, function(x) rate(x$n, x$period))
}

#' @export
get_precision.rate_limited_function <- function(f) {
    attr(f, "info")()[[1]]$precision
}

#' @export
get_function.rate_limited_function <- function(f) {
    attr(f, "func")
}

#' @export
get_rates.limited_function_list <- function(f) {
    get_rates(f[[1]])
}

#' @export
get_precision.limited_function_list <- function(f) {
    get_precision(f[[1]])
}
