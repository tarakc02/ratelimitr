context("rate limits work when function doesn't return")

test_that("rate limits still work in face of errors", {
    call_log <- rep(NA, 100)
    counter <- 1L
    f <- function() {
        call_log[counter] <<- Sys.time()
        counter <<- counter + 1L
        if (runif(1) > .25) stop("blalh")
        TRUE
    }

    n <- 4L
    period <- .2

    safe_f <- function() tryCatch(f(), error = function(e) FALSE)
    f_lim <- limit_rate(safe_f, rate(n = n, period = period))
    res <- replicate(100, f_lim())

    lagged_log <- c(rep(NA, n + 1), call_log[seq_len(100 - (n + 1))])
    times <- call_log - lagged_log
    expect_gt(min(times, na.rm = TRUE), period)
})
