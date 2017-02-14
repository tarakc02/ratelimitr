context("running window tests")

test_that("rate limited function is always in compliance", {
    if(require("microbenchmark", quietly = TRUE)) {
        f <- limit_rate(microbenchmark::get_nanotime, rate(n = 5, period = .03))
        res <- replicate(100, f())
        lagged_res <- c(rep(NA, 6), res[seq_len(94)])
        times <- (res - lagged_res) / 1E9
        expect_gt(min(times, na.rm = TRUE), .03)
    }
})

test_that("no failures in a long window", {
    skip_on_cran()
    iter <- 10000
    n <- 5
    period <- .03
    f <- limit_rate(microbenchmark::get_nanotime, rate(n = n, period = period))
    res <- replicate(iter, f())
    lagged_res <- c(rep(NA, n + 1), res[seq_len(iter - (n + 1))])
    times <- (res - lagged_res) / 1E9
    expect_gt(min(times, na.rm = TRUE), .03)
})
