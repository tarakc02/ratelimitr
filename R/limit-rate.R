#' Limit the rate at which a function will execute
#'
#' @param f The function to be rate-limited
#' @param ... One or more rates, created using \code{\link{rate}}
#'
#' @export
limit_rate <- function(f, ..., precision = 60) {
    rates <- list(...)
    limit_rate_(f, rates, precision = precision)
}

limit_rate_ <- function(f, rates, precision) {
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
            period = rate[["period"]],
            precision = precision)
    )

    newf <- function(...) {
        is_good <- vapply(gatekeepers, request,
                          FUN.VALUE = logical(1), policy = wait)
        if (all(is_good)) return(f(...))
        stop("Unexpected error")
    }

    structure(newf,
              func = f, rates = rates, precision = precision,
              class = c("rate_limited_function", class(f)))
}

#' @export
reset <- function(f) UseMethod("reset")

#' @export
reset.rate_limited_function <- function(f)
    limit_rate_(attr(f, "func"), rates = attr(f, "rates"),
                precision = attr(f, "precision"))

#' @export
print.rate_limited_function <- function(f) {
    rates <- attr(f, "rates")
    func <- attr(f, "func")
    precision <- attr(f, "precision")

    catrate <- function(rate) {
        cat("    ", rate[["n"]], "calls per", rate[["period"]], "seconds\n")
    }

    cat("A rate limited function, with rates (within 1/", precision, " seconds):\n", sep = "")
    lapply(rates, catrate)
    print(func)
    invisible(f)
}
