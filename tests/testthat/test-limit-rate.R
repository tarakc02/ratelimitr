context("main")

test_that("rate limited function does not exceed limits", {
    f <- function() NULL
    rates <- list(
        c(n = 10, period = .01),
        c(n = 50, period = .1)
    )
    f_lim <- limit_rate(f, rates = rates)
    time11 <- system.time(replicate(11, f_lim()))[["elapsed"]]
    expect_gt(time11, .01)

    f_lim <- limit_rate(f, rates = rates)
    time51 <- system.time(replicate(51, f_lim()))[["elapsed"]]
    expect_gt(time51, .1)
})
