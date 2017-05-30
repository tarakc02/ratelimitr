* Due to inherent imprecision of `Sys.sleep`, there were rare occasions where rate-limited functions displayed unexpected and wrong behavior (see #12 and #13). In order to fix the problem, rate-limited functions now wait at least .02 seconds longer than necessary.
* Use `proc.time` instead of `Sys.time` to measure time (for increased precision).

# ratelimitr 0.3.7

* Edit unit tests so that tests relying on microbenchmark ("Suggests") are conditional on microbenchmark's presence

# ratelimitr 0.3.6

* Added a `NEWS.md` file to track changes to the package.
* First release on CRAN
