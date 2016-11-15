context("repeated tests")

test_that("rates are consistently obeyed", {
    f <- function() NULL
    f_lim <- limit_rate(f, rate(n = 10, period = .1))

    logger <- function() {
        system.time(replicate(11, f_lim()))[["elapsed"]]
    }

    res <- replicate(100, logger())

    expect_false(any(res <= .1))
})

