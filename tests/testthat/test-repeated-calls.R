context("repeated tests")

test_that("rates are consistently obeyed", {
    f <- function() NULL
    f_lim <- limit_rate(f, rate(n = 10, period = .03))

    logger <- function() {
        f_lim <- reset(f_lim)
        system.time(replicate(11, f_lim()))[["elapsed"]]
    }

    res <- replicate(20, logger())

    expect_false(any(res <= .03))
})

