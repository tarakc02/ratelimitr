context("running window tests")

test_that("rate limited function is always in compliance", {
    f <- limit_rate(microbenchmark::get_nanotime, rate(n = 5, period = .03))
    res <- replicate(100, f())
    lagged_res <- c(rep(NA, 6), res[seq_len(94)])
    times <- (res - lagged_res) / 1E9
    expect_gt(min(times, na.rm = TRUE), .03)
})
