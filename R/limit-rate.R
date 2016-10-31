#' @export
limit_rate <- function(f, ...) {
    rates <- list(...)
    limit_rate_(f, rates)
}

limit_rate_ <- function(f, rates) {
    request <- request.token_dispenser
    is_rate <- function(rt) {
        if (!inherits(rt, "rate_limit"))
            stop("Invalid rate")
        return(TRUE)
    }

    is_valid_rate <- vapply(rates, is_rate, FUN.VALUE = logical(1))
    if (any(!is_valid_rate)) stop("Input error")

    gatekeepers <- lapply(rates, function(rate)
        token_dispenser(
            n = rate[["n"]],
            period = rate[["period"]])
    )

    newf <- function(...) {
        is_good <- vapply(gatekeepers, request, FUN.VALUE = logical(1))
        if (all(is_good)) return(f(...))
        stop("Unexpected error")
    }

    structure(newf,
              func = f, rates = rates,
              class = c("rate_limited_function", class(f)))
}

#' @export
reset <- function(f) UseMethod("reset")

#' @export
reset.rate_limited_function <- function(f)
    limit_rate_(attr(f, "func"), rates = attr(f, "rates"))
