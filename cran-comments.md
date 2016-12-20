## Resubmission
This is a patch to a submission from yesterday. In the previous version, a function from a package listed as "Suggests" (microbenchmark) was used unconditionally in unit tests, causing the build to fail on systems that don't have microbenchmark available. Calls to functions from suggested packages are now conditional. I tested on a system without microbenchmark, and R CMD check finished with no errors or warnings, and one expected NOTE: "Package suggested but not available for checking: 'microbenchmark'". On systems with microbenchmark available, R CMD check results are printed below.

## Test environments
* ubuntu 14.04, R 3.3.2
* ubuntu 12.04 (on travis-ci), R 3.3.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.

---
