
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
#>    0.00    0.00    1.01
```

You can add multiple rates

``` r
# see section "limitations" for reasoning behind adding .02 to the periods
f_lim <- limit_rate(
    f, 
    rate(n = 10, period = .12), 
    rate(n = 50, period = 1.02)
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
#>  expr         min          lq        mean    median          uq
#>  do10    2.995833    3.095428    3.373268    3.2701    3.621913
#>  do11  113.960635  122.012625  123.708249  123.4575  126.680666
#>  do50  481.293625  486.912000  494.445336  490.5609  503.991403
#>  do51 1021.917364 1023.542055 1027.716492 1026.0042 1032.439082
#>          max neval  cld
#>     3.990262    10 a   
#>   135.301716    10  b  
#>   511.796306    10   c 
#>  1034.910330    10    d
```

If you have multiple functions that should collectively be subject to a single rate limit, see the [vignette on limiting multiple functions](https://github.com/tarakc02/ratelimitr/blob/master/vignettes/multi-function.md).

Limitations
-----------

Rate limiting utilizes `Sys.sleep()` to pause when necessary, and so is constrained to the same time resolution (see `?Sys.sleep`). In many cases, this is good enough, but if you need to make sure you are strictly obeying the limits, you can add a buffer of .02 seconds or so to the `period` (eg instead of 10 calls per second, you might set it up as 10 calls per 1.02 seconds).

To install:
-----------

``` r
devtools::install_github("tarakc02/ratelimitr")
```

Requirements
------------

-   R
-   [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)
