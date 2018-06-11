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
