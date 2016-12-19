context("function integerity")

test_that("new functions inherit formal arguments from originals", {
    # see also issue 9
    f <- function(x, y = TRUE) if (y) x else -x
    g <- limit_rate(f, rate(10, 1))
    expect_equal(formals(f), formals(g))
})

test_that("new functions have same outputs as originals", {
    f <- limit_rate(mean, rate(100, .1))
    rand <- runif(20)

    expect_identical(
        f(rand), mean(rand)
    )

    f <- function() stop("stop")
    g <- limit_rate(f, rate(10, 1))

    err_f <- tryCatch(f(), error = function(e) e)
    err_g <- tryCatch(g(), error = function(e) e)

    expect_identical(
        err_f$message, err_g$message
    )
    expect_identical(
        class(err_f), class(err_g)
    )
})

test_that("functions can be called in weird ways", {
    f <- limit_rate(mean, rate(100, .1))

    env <- new.env(parent = baseenv())
    env$rand <- runif(20)
    env$f <- f
    expect_identical(
        f(env$rand),
        eval(quote(f(rand)), envir = env)
    )
    expect_identical(
        f(env$rand),
        eval(substitute(f(rand), env = env))
    )
})
