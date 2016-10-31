
<!-- README.md is generated from README.Rmd. Please edit that file -->
ratelimitr
----------

Use ratelimitr to limit the rate at which functions are called.

``` r
library(ratelimitr)
f <- function() NULL

# create a version of f that can only be called 10 times per 3 seconds
f_lim <- limit_rate(f, rates = list(
    c(n = 10, period = 3)
))


system.time(replicate(11, f()))
#>    user  system elapsed 
#>       0       0       0

system.time(replicate(11, f_lim()))
#>    user  system elapsed 
#>   0.002   0.000   3.004
```

You can add multiple rates

``` r
f_lim <- limit_rate(f, rates = list(
    c(n = 10, period = .01),
    c(n = 50, period = .1)
))

timef <- function(n) {
    replicate(n, f_lim())
    reset(f_lim)
}

library(microbenchmark)
microbenchmark(
    f_lim <- timef(10),
    f_lim <- timef(11),
    f_lim <- timef(50),
    f_lim <- timef(51),
    times = 20L
)
#> Unit: milliseconds
#>                expr        min         lq      mean     median         uq
#>  f_lim <- timef(10)   3.448922   4.548046   6.68915   6.405786   8.279273
#>  f_lim <- timef(11)  12.156866  12.636333  14.07767  14.068316  14.782000
#>  f_lim <- timef(50)  48.748911  49.742735  51.06710  50.414349  52.404456
#>  f_lim <- timef(51) 104.063934 104.515356 106.07174 106.085464 107.109385
#>        max neval  cld
#>   11.82666    20 a   
#>   17.72554    20  b  
#>   55.38878    20   c 
#>  110.03611    20    d
```
