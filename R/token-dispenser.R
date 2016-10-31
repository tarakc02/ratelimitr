token_dispenser <- function(n, period) {
    init_time <- as.numeric(Sys.time())

    tokens <- new(queue)
    replicate(n, tokens$push(init_time))

    request <- function() {
        now <- as.numeric(Sys.time())
        if (tokens$size() != n)
            stop("Unexpected error")
        token <- tokens$front()
        if (now >= token) {
            tokens$pop()
            tokens$push(now + period)
            return(TRUE)
        }

        time_to_wait <- token - now
        Sys.sleep(time_to_wait)
        request()
    }
    structure(request, class = "token_dispenser")
}

request <- function(x) UseMethod("request")
request.token_dispenser <- function(x) x()

# bloop <- dispenser(10, .1)
# system.time(replicate(11, bloop()))
#
# library(microbenchmark)
# microbenchmark(
#     bloop <- dispenser(10, .1),
#     replicate(9, bloop()),
#     bloop <- dispenser(10, .1),
#     replicate(11, bloop())
# )
