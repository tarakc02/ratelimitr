get_rates <- function(f) UseMethod("get_rates")
get_precision <- function(f) UseMethod("get_precision")
get_function <- function(f) UseMethod("get_function")

get_rates.rate_limited_function <- function(f) {
    info <- attr(f, "info")()
    lapply(info, function(x) rate(x$n, x$period))
}

get_precision.rate_limited_function <- function(f) {
    attr(f, "info")()[[1]]$precision

}

get_function.rate_limited_function <- function(f) {
    attr(f, "func")
}

get_rates.limited_function_list <- function(f) {
    get_rates(f[[1]])
}

get_precision.limited_function_list <- function(f) {
    get_precision(f[[1]])
}
