
<!-- README.md is generated from README.Rmd. Please edit that file -->
ratelimitr
----------

Use ratelimitr to limit the rate at which functions are called.

``` r
library(ratelimitr)
f <- function() NULL

# create a version of f that can only be called 10 times per second
f_lim <- limit_rate(f, rate(n = 10, period = 1))

# time without limiting
system.time(replicate(11, f()))
#>    user  system elapsed 
#>   0.000   0.000   0.001

# time with limiting
system.time(replicate(11, f_lim()))
#>    user  system elapsed 
#>   0.002   0.000   1.002
```

You can add multiple rates

``` r
f_lim <- limit_rate(
    f, 
    rate(n = 10, period = .01), 
    rate(n = 50, period = .1)
)

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
#>  do10   3.914986   5.681779   6.649787   6.439666   7.433393  10.26257
#>  do11  12.289115  12.406203  13.528122  13.230466  14.566590  15.58756
#>  do50  48.961195  49.347310  50.562922  49.932887  50.863414  55.87466
#>  do51 104.185447 105.140098 106.377938 106.604095 107.132279 111.72468
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
