ratelimitr
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/tarakc02/ratelimitr.svg?branch=master)](https://travis-ci.org/tarakc02/ratelimitr)

Introduction
------------

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
#>   0.002   0.004   1.024
```

Multiple rates
--------------

Published rate limits often have multiple types of limits. Here is an example of limiting a function so that it never evaluates more than 10 times per .1 seconds, but additionally never evaluates more than 50 times per 1 second.

``` r
f_lim <- limit_rate(
    f, 
    rate(n = 10, period = .1), 
    rate(n = 50, period = 1)
)

# 10 calls do not trigger the rate limit
system.time(replicate(10, f_lim()))
#>    user  system elapsed 
#>   0.002   0.000   0.002

# sleeping in between tests to re-set the rate limit timer
Sys.sleep(1)

# 11 function calls do trigger the rate limit
system.time(replicate(11, f_lim())); Sys.sleep(1)
#>    user  system elapsed 
#>   0.011   0.000   0.128

# similarly, 50 calls don't trigger the second rate limit
system.time(replicate(50, f_lim())); Sys.sleep(1)
#>    user  system elapsed 
#>   0.052   0.004   0.525

# but 51 calls do:
system.time(replicate(51, f_lim())); Sys.sleep(1)
#>    user  system elapsed 
#>   0.086   0.000   1.025
```

Multiple functions sharing one (or more) rate limit(s)
------------------------------------------------------

To limit a group of functions together, just pass `limit_rate` a list of functions instead of a single function. Make sure the list is named, the names will be how you access the rate-limited versions of the functions:

``` r
f <- function() 1
g <- function() 2
h <- function() 3

# passing a named list to limit_rate
limited <- limit_rate(list(f = f, g = g, h = h), rate(n = 3, period = 1))

# now limited is a list of functions that share a rate limit. examples:
limited$f()
#> [1] 1
limited$g()
#> [1] 2
```

The new functions are subject to a single rate limit, regardless of which ones are called or in what order they are called.

``` r
# the first three function calls should not trigger a delay
system.time(
    {limited$f(); limited$g(); limited$h()}
)
#>    user  system elapsed 
#>   0.001   0.000   0.001

# sleep in between tests to reset the rate limit timer
Sys.sleep(1)

# but to evaluate a fourth function call, there will be a delay
system.time(
    {limited$f(); limited$g(); limited$h(); limited$f()}
)
#>    user  system elapsed 
#>   0.010   0.000   1.027
```

Limitations
-----------

`limit_rate` is not safe to use in parallel.

The precision with which you can measure the length of time that has elapsed between two events is constrained to some degree, dependent on your operating system. In order to guarantee compliance with rate limits, this package truncates the time (specifically taking the ceiling or the floor based on which would give the most conservative estimate of elapsed time), rounding to the fraction specified in the `precision` argument of `token_dispenser` -- the default is 60, meaning time measurements are taken up to the 1/60th of a second. While the conservative measurements of elapsed time make it impossible to overrun the rate limit by a tiny fraction of a second (see [Issue 3](https://github.com/tarakc02/ratelimitr/issues/3)), they also will result in waiting times that are slightly longer than necessary (using the default `precision` of 60, waiting times will be .01-.03 seconds longer than necessary).

Installation
------------

This package is not yet on CRAN. Install from github using devtools:

``` r
devtools::install_github("tarakc02/ratelimitr")
```
