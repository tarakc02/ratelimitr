
<!-- README.md is generated from README.Rmd. Please edit that file -->
ratelimitr
----------

Use ratelimitr to limit the rate at which functions are called. A rate-limited function that allows `n` calls per `period` will never have a window of time of length `period` that includes more than `n` calls.

``` r
library(ratelimitr)
f <- function() NULL

# create a version of f that can only be called 10 times per second
f_lim <- limit_rate(f, rate(n = 10, period = 1))

# time without limiting
system.time(replicate(11, f()))
#>    user  system elapsed 
#>       0       0       0

# time with limiting
system.time(replicate(11, f_lim()))
#>    user  system elapsed 
#>    0.00    0.00    1.05
```

You can add multiple rates

``` r
# see section "limitations" for reasoning behind adding .02 to the periods
f_lim <- limit_rate(
    f, 
    rate(n = 10, period = .1), 
    rate(n = 50, period = 1)
)

# reset function is for convenience. it does not modify the original 
# rate-limited function, just returns a new one
timef <- function(n) {
    replicate(n, f_lim())
    reset(f_lim)
}

library(microbenchmark)
microbenchmark(
    do10 = f_lim <- timef(10),
    do11 = f_lim <- timef(11),
    do50 = f_lim <- timef(50),
    do51 = f_lim <- timef(51),
    times = 10L
) 
#> Unit: milliseconds
#>  expr        min         lq       mean     median         uq        max
#>  do10   20.84926   21.12105   26.33994   26.16915   31.54378   32.65489
#>  do11  120.41504  138.37152  145.07101  147.14811  155.85931  157.23804
#>  do50  488.20824  497.71106  517.86313  527.89816  532.68777  533.43093
#>  do51 1027.78964 1032.32912 1045.65367 1046.61243 1054.05154 1062.92562
#>  neval  cld
#>     10 a   
#>     10  b  
#>     10   c 
#>     10    d
```

If you have multiple functions that should collectively be subject to a single rate limit, see the [vignette on limiting multiple functions](https://github.com/tarakc02/ratelimitr/blob/master/vignettes/multi-function.md).

Limitations
-----------

The precision with which you can measure the length of time that has elapsed between two events is constrained to some degree, dependent on your operating system. In order to guarantee compliance with rate limits, this package truncates the time (specifically taking the ceiling or the floor based on which would give the most conservative estimate of elapsed time), rounding to the fraction specified in the `precision` argument of `token_dispenser` -- the default is 60, meaning time measurements are taken up to the 1/60th of a second. While the conservative measurements of elapsed time make it impossible to overrun the rate limit by a tiny fraction of a second (see [Issue 3](https://github.com/tarakc02/ratelimitr/issues/3)), they also will result in waiting times that are slightly longer than necessary (using the default `precision` of 60, waiting times will be .01-.03 seconds longer than necessary) .

To install:
-----------

``` r
devtools::install_github("tarakc02/ratelimitr")
```

Requirements
------------

-   R
-   [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)
