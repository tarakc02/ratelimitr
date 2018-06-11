context("updating rate limits")

timer <- function(expr) {
    round(system.time(expr)[["elapsed"]], 3)
}

test_that("can update rate of existing function, and it obeys the new rate", {
    f <- function() NULL

    f_lim <- limit_rate(
        f,
        rate(n = 5, period = .1),
        precision = 60
    )

    tm <- timer(replicate(6, f_lim()))
    expect_gt(tm, .1)

    UPDATE_RATE(f_lim, rate(n = 3, period = .1))
    tm2 <- timer(replicate(4, f_lim()))
    expect_gt(tm2, .1)
})
