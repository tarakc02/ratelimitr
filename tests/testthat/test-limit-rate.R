context("main")

test_that("rate limited function does not exceed limits", {
    f <- function() NULL
    rates <- list(
        rate(n = 10, period = .1),
        rate(n = 50, period = 1)
    )
    f_lim <- limit_rate_(f, rates = rates, precision = 60)
    time11 <- system.time(replicate(11, f_lim()))[["elapsed"]]
    expect_gt(time11, .1)

    f_lim <- limit_rate_(f, rates = rates, precision = 60)
    time51 <- system.time(replicate(51, f_lim()))[["elapsed"]]
    expect_gt(time51, 1)
})
