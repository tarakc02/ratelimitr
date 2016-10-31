
<!-- README.md is generated from README.Rmd. Please edit that file -->
ratelimitr
----------

Use ratelimitr to limit the rate at which functions are called.

``` r
library(ratelimitr)
f <- function() NULL

# create a version of f that can only be called 10 times per .01 seconds
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
    f_lim <- timef(9),
    f_lim <- timef(11),
    f_lim <- timef(49),
    f_lim <- timef(51)
)
#> Unit: milliseconds
#>                expr        min         lq       mean     median        uq
#>   f_lim <- timef(9)   3.363942   4.011565   5.939788   5.385796   7.16680
#>  f_lim <- timef(11)  12.225299  12.412299  13.678855  13.337286  14.12729
#>  f_lim <- timef(49)  45.429961  49.197821  50.808944  50.431432  51.94201
#>  f_lim <- timef(51) 102.654566 105.651198 106.347749 106.376098 107.20456
#>        max neval  cld
#>   12.63568   100 a   
#>   21.94518   100  b  
#>   61.86623   100   c 
#>  109.94926   100    d
```
