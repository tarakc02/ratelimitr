context("repeated tests")

test_that("rates are consistently obeyed", {
    f <- function() NULL
    f_lim <- limit_rate(f, rate(n = 10, period = .03))

    logger <- function() {
        Sys.sleep(.05)
        system.time(replicate(11, f_lim()))[["elapsed"]]
    }

    res <- replicate(20, logger())

    expect_false(any(res <= .03))
})

