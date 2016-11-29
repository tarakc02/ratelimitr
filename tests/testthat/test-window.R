context("running window tests")

test_that("rate limited function is always in compliance", {
    f <- limit_rate(Sys.time, rate(n = 5, period = .03))
    res <- replicate(100, f())
    lagged_res <- c(rep(NA, 5), res[seq_len(95)])
    times <- res - lagged_res
    expect_gt(min(times, na.rm = TRUE), .03)
})
