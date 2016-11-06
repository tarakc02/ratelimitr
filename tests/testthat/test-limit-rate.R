context("main")

test_that("rate limited function does not exceed limits", {
    f <- function() NULL

    f_lim <- limit_rate(
        f,
        rate(n = 10, period = .1),
        rate(n = 50, period = 1),
        precision = 60
    )

    time11 <- system.time(replicate(11, f_lim()))[["elapsed"]]
    expect_gt(time11, .1)

    f_lim <- limit_rate(
        f,
        rate(n = 10, period = .1),
        rate(n = 50, period = 1),
        precision = 60
    )

    time51 <- system.time(replicate(51, f_lim()))[["elapsed"]]
    expect_gt(time51, 1)
})

test_that("rate-limited groups of functions obey rate limits", {
    f <- function() NULL
    g <- function() NULL

    limited <- limit_rate(list(f = f, g = g), rate(n = 2, period = 1))
    evaltime <- system.time(
        {limited$f(); limited$g(); limited$f()}
    )[["elapsed"]]

    expect_gt(evaltime, 1)
})
