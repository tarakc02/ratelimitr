context("repeated tests")

test_that("rates are consistently obeyed", {
    if(require("microbenchmark", quietly = TRUE)) {
        f <- function() NULL
        f_lim <- limit_rate(f, rate(n = 10, period = .03))

        timer <- function() {
            start <- microbenchmark::get_nanotime()
            replicate(11, f_lim())
            end <- microbenchmark::get_nanotime()
            f_lim <- reset(f_lim)
            (end - start) / 1E9
        }

        res <- replicate(20, timer())

        expect_false(any(res <= .03))
    }
})

