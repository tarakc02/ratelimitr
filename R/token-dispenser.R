token_dispenser <- function(n, period, precision = 60) {
    assert_that(is.count(n))
    assert_that(is.number(period))

    # times should be in increments of (1 / precision) of seconds
    # So period (entered in seconds) is converted to period * precision
    period <- period * precision

    init_time <- ceiling(as.numeric(Sys.time()) * precision)

    tokens <- fixed_queue(n)
    replicate(n, push(tokens, init_time))

    request <- function() {
        now <- floor(as.numeric(Sys.time()) * precision)
        token <- front(tokens)
        if (now > token) {
            pop(tokens)
            push(tokens, ceiling(as.numeric(Sys.time()) * precision) + period)
            return(TRUE)
        }

        # wait time should be converted back to whole seconds
        time_to_wait <- (token - now) / precision
        signalCondition(rate_limit_exception(time_to_wait))
    }
    structure(request, class = "token_dispenser")
}

request <- function(x, policy = wait) {
    tryCatch(
        x(),
        rate_limit_exception = function(e) policy(x, e),
        error = function(e) stop(e$message, call. = FALSE)
    )
}
