Limiting multiple functions with a single rate
================
Tarak Shah
2016-10-31

-   [Set up](#set-up)
-   [The token dispenser](#the-token-dispenser)
-   [Modify original functions](#modify-original-functions)
-   [Enjoy!](#enjoy)

In many web APIs, several search endpoints are exposed, and the client is expected to abide by a single rate limit, regardless of search endpoint. On the client side, that means we have to subject more than one function to a shared rate limit. This vignette shows how to do this, using the `token_dispenser` function.

Set up
------

To be concrete, imagine we have three functions which all access the same shared resource, and are subject to a shared rate limit:

``` r
f1 <- function() 1
f2 <- function(x = 1, y = 1) x + y
f3 <- function(x = 1, y = 2, z = 3) (x * y) + z
```

We want to use these functions freely, but also to ensure that, in total, they don't execute more than 3 times per second. This may mean three calls to `f1`, or it may mean one call each to `f1`, `f2`, and `f3`, etc..

The token dispenser
-------------------

The way we'll accomplish this multi-function rate limiting is by setting up a token dispenser which provides each function permission to execute. A `token_dispenser` is inititalized with the number of tokens and the length of the measurement period:

``` r
library(ratelimitr)

# a dispenser which dispenses no more than 3 tokens per second
permission <- token_dispenser(3, 1)
```

Modify original functions
-------------------------

We now modify the original functions so that they each request a token before proceeding. Importantly, we have them all request a token from the same dispenser, so that they collectively share the implied rate limit.

``` r
f1 <- function() if(request(permission)) 1
f2 <- function(x = 1, y = 1) if(request(permission)) x + y
f3 <- function(x = 1, y = 2, z = 3) if(request(permission)) (x * y) + z
```

Enjoy!
------

That's it! `f1`, `f2`, and `f3` are now collectively rate limited to 3 total calls per second. It doesn't matter which one is called, or what order, the rate limit will still be obeyed:

``` r
# a test function that will randomly pick f1, f2, or f3
run_one <- function() {
    funs <- list(f1 = f1, f2 = f2, f3 = f3)
    selected_fun <- sample(3, 1)
    
    funs[[selected_fun]]()
}

# each time we call run_one(), one of the functions will call with default arguments
replicate(5, run_one())
```

    ## [1] 1 1 2 5 2

``` r
# regardless of how they are called, the rate of the calls of f1, f2, and f3 will be limited by the token_dispenser

# sleep before each trial to re-set the timer
Sys.sleep(1)

# 3 calls should not trigger the rate limit
system.time(replicate(3, run_one()))
```

    ##    user  system elapsed 
    ##    0.01    0.00    0.01

``` r
Sys.sleep(1)

# but there will be a pause before the 4th call, since we are limited to 
# a maximum of 3 calls per second
system.time(replicate(4, run_one()))
```

    ##    user  system elapsed 
    ##    0.00    0.00    1.03

``` r
Sys.sleep(1)
system.time(replicate(9, run_one()))
```

    ##    user  system elapsed 
    ##    0.01    0.00    2.02

``` r
Sys.sleep(1)

# similarly, a delay will be imposed before the 10th call -- we shouldn't 
# be able to call more than 9 functions in 3 seconds.
system.time(replicate(10, run_one()))
```

    ##    user  system elapsed 
    ##    0.00    0.00    3.01