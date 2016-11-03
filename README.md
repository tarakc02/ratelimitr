
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
#>  expr         min         lq       mean     median         uq        max
#>  do10    4.691159   31.09181   28.98221   31.26096   32.48802   33.47939
#>  do11  154.130490  154.65773  155.67734  155.62705  156.21473  158.09788
#>  do50  523.860443  531.67321  532.99834  532.72940  533.20437  543.76736
#>  do51 1032.071018 1037.89762 1050.34917 1049.20700 1063.18411 1067.94179
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

Please note, this package is brand new and still heavily in development. The API will still change, `ratelimitr` should not be considered stable. Please report any bugs or missing features. Thanks!

Requirements
------------

-   R
-   [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)
