context("function integerity")

test_that("new functions inherit formal arguments from originals", {
    # see also issue 9
    f <- function(x, y = TRUE) if (y) x else -x
    g <- limit_rate(f, rate(10, 1))
    expect_equal(formals(f), formals(g))
})
