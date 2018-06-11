context("works with web APIs despite network lag")

test_that("requests are received no faster than the allowed rate", {

    # a function that contains a variable "lag" to
    # represent network lag
    http_request <- function(lag) {
        Sys.sleep(lag)
        TRUE
    }

    # the rate-limited version
    rl_http_request <- limit_rate(
        http_request,
        rate(n = 1, period = .5))

    mock_server <- function(limit = .5) {
        previous_request <- NULL

        function() {
            now <- proc.time()[["elapsed"]]

            # return FALSE if we broke the rate limit
            if (!is.null(previous_request) &&
                now - previous_request <= limit) return(FALSE)

            # otherwise log the time and return TRUE
            previous_request <<- now
            return(TRUE)
        }
    }

    mock_http <- function(limit = .5) {
        server <- mock_server(limit = limit)

        function(lag) {
            # we make the request locally
            # it may lag though
            result <- rl_http_request(lag)

            # then the request reaches the server:
            server()
        }
    }

    probe <- mock_http(limit = .5)

    # now we have a request with a long lag followed immediately
    # by a request with no lag
    responses <- c(probe(1), probe(0))
    expect_true(all(responses))
})
