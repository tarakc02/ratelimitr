context("reset")

test_that("reset works properly for single functions", {
    f <- function() NULL
    f_lim <- limit_rate(f, rate(2, .2))

    start_time <- microbenchmark::get_nanotime()
    replicate(2, f_lim())
    f_lim2 <- reset(f_lim)

    t2 <- system.time(replicate(2, f_lim2()))[["elapsed"]]
    expect_lt(t2, .2)

    f_lim()
    end_time <- microbenchmark::get_nanotime()
    exec_time <- (end_time - start_time) / 1E9
    expect_gt(exec_time, .2)
})

test_that("reset works properly for lists of functions", {
    # see issue 8
    f <- function() "f"
    g <- function() "g"
    ratelim <- .1

    limited <- limit_rate(
        list(
            f = f,
            g = g
        ),
        rate(n = 1, period = ratelim)
    )

    t1 <- system.time({
        limited$f(); limited$g()
    })[["elapsed"]]
    expect_gt(t1, ratelim)

    limited2 <- reset(limited)

    t2 <- system.time({
        limited2$f(); limited2$g()
    })[["elapsed"]]
    expect_gt(t2, ratelim)

    t1_a <- system.time({
        limited$f(); limited$g()
    })[["elapsed"]]
    expect_gt(t1_a, ratelim)
})
