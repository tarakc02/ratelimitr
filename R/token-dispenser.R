time_now <- function()
    proc.time()[["elapsed"]]

token_dispenser <- function(n, period, precision = 60) {
    assert_that(is.count(n))
    assert_that(is.number(period))
    original_period <- period

    # times should be in increments of (1 / precision) of seconds
    # So period (entered in seconds) is converted to period * precision
    period <- period * precision

    init_time <- ceiling(time_now() * precision)

    tokens <- fixed_queue(n)
    replicate(n, push(tokens, init_time))

    request <- function() {
        now <- floor(time_now() * precision)
        token <- front(tokens)
        if (now > token) {
            pop(tokens)
            return(TRUE)
        }

        # wait time should be converted back to whole seconds
        time_to_wait <- (token - now) / precision
        signalCondition(rate_limit_exception(time_to_wait))
    }

    deposit <- function() {
        push(tokens, ceiling(time_now() * precision) + period)
        return(TRUE)
    }

    dispatch <- function(action) {
        switch(action,
               "request" = request,
               "deposit" = deposit,
               "info" = list(n = n, period = original_period, precision = precision))
    }

    structure(dispatch, class = "token_dispenser")
}

request <- function(x, policy = wait) {
    tryCatch(
        x("request")(),
        rate_limit_exception = function(e) policy(x, e),
        error = function(e) stop(e$message, call. = FALSE)
    )
}

deposit <- function(x) {
    x("deposit")()
}
