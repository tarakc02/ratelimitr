context("main")

timer <- function(expr) {
    round(system.time(expr)[["elapsed"]], 3)
}

test_that("rate limited function does not exceed limits", {
    f <- function() NULL

    f_lim <- limit_rate(
        f,
        rate(n = 10, period = .05),
        rate(n = 40, period = .5),
        precision = 60
    )

    time11 <- timer(replicate(11, f_lim()))
    expect_gt(time11, .05)

    f_lim <- limit_rate(
        f,
        rate(n = 10, period = .05),
        rate(n = 40, period = .5),
        precision = 60
    )

    time41 <- timer(replicate(41, f_lim()))
    expect_gt(time41, .5)
})

test_that("rate-limited groups of functions obey rate limits", {
    f <- function() NULL
    g <- function() NULL

    limited <- limit_rate(list(f = f, g = g), rate(n = 2, period = .1))
    evaltime <- timer(
        {limited$f(); limited$g(); limited$f()}
    )

    expect_gt(evaltime, .1)
})
