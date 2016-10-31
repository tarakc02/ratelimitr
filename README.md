
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
#>   0.001   0.000   0.000

# time with limiting
system.time(replicate(11, f_lim()))
#>    user  system elapsed 
#>   0.001   0.000   1.001
```

You can add multiple rates

``` r
f_lim <- limit_rate(
    f, 
    rate(n = 10, period = .01), 
    rate(n = 50, period = .1)
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
    times = 20L
)
#> Unit: milliseconds
#>  expr        min         lq       mean     median         uq       max
#>  do10   3.594345   3.690182   6.162223   5.502054   8.413349  10.02397
#>  do11  12.290057  12.392184  13.629930  13.116848  14.960611  15.84700
#>  do50  44.736207  49.716743  51.191375  50.983907  52.783065  56.65859
#>  do51 103.517197 106.499825 106.685075 106.858432 107.136684 107.72976
#>  neval  cld
#>     20 a   
#>     20  b  
#>     20   c 
#>     20    d
```

To install:
-----------

``` r
devtools::install_github("tarakc02/ratelimitr")
```

Requirements
------------

-   R
-   [Rcpp](https://cran.r-project.org/web/packages/Rcpp/index.html)
