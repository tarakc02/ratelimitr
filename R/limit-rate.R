#' Limit the rate at which a function will execute
#'
#' @param f A single function to be rate-limited, or a named list of functions
#' @param ... One or more rates, created using \code{\link{rate}}
#' @param precision The precision with which time intervals can be measured, in hertz
#'
#' @return If \code{f} is a single function, then a new function with the same
#' signature and (eventual) behavior as the original function, but rate limited.
#' If \code{f} is a named list of functions, then a new list of functions with the
#' same names and signatures, but collectively bound by a shared rate limit.
#'
#' @examples
#' ## limiting a single function
#' f <- limit_rate(Sys.time, rate(n = 5, period = .1))
#' res <- replicate(10, f())
#' ## show the elapsed time between each function call:
#' round(res[-1] - head(res, -1), 3)
#'
#' ## for multiple functions, make sure the list is named:
#' f <- function() 1
#' g <- function() 2
#' limited <- limit_rate(list(f = f, g = g), rate(n = 1, period = .1))
#' system.time({limited$f(); limited$g()})
#'
#' @seealso \code{\link{rate}}
#'
#' @name limit_rate
#' @export
limit_rate <- function(f, ..., precision = 60) UseMethod("limit_rate")

check_rates <- function(rates) {
    is_rate <- function(rt) {
        if (!inherits(rt, "rate_limit"))
            stop("Invalid rate")
        return(TRUE)
    }

    is_valid_rate <- vapply(rates, is_rate, FUN.VALUE = logical(1))
    if (any(!is_valid_rate)) stop("Input error")
}

#' @rdname limit_rate
#' @export
limit_rate.list <- function(f, ..., precision = 60) {
    flist <- do.call(function_list, f)
    limit_rate.function_list(flist, ..., precision = 60)
}

#' @rdname limit_rate
#' @export
limit_rate.function_list <- function(f, ..., precision = 60) {
    rates <- list(...)
    check_rates(rates)

    gatekeepers <- lapply(rates, function(rate)
        token_dispenser(
            n = rate[["n"]],
            period = rate[["period"]],
            precision = precision)
    )

    build_function <- function(fun) {
        newfun <- function(...) {
            args <- as.list(match.call())[-1]
            args <- lapply(
                args,
                eval, envir = parent.frame()
            )
            nf <- c(
                quote(fun),
                args
            )
            is_good <- vapply(gatekeepers, request,
                              FUN.VALUE = logical(1), policy = wait)
            if (all(is_good)) return(eval(as.call(nf)))
            stop("Unexpected error")
        }
        formals(newfun) <- formals(args(fun))

        structure(
            newfun,
            func = fun,
            rates = rates,
            precision = precision,
            class = c("rate_limited_function", class(fun))
        )
    }

    new_functions <- lapply(f, build_function)
    structure(new_functions, class = c("limited_function_list", "function_list"))
}

#' @rdname limit_rate
#' @export
limit_rate.function <- function(f, ..., precision = 60) {
    limit_rate(list(f = f), ..., precision = precision)[["f"]]
}

#' @export
print.rate_limited_function <- function(x, ...) {
    f <- x
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

#' @export
print.limited_function_list <- function(x, ...) {
    flist <- x
    rates <- attr(flist[[1]], "rates")
    precision <- attr(flist[[1]], "precision")

    catrate <- function(rate) {
        cat("    ", rate[["n"]], "calls per", rate[["period"]], "seconds\n")
    }

    cat("A rate limited group of functions, with rates (within 1/",
        precision, " seconds):\n", sep = "")
    lapply(rates, catrate)

    lapply(flist, function(f) print(attr(f, "func")))
    invisible(x)

}
