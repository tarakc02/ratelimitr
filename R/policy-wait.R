wait <- function(tokens, exception) {
    Sys.sleep(exception$wait_time)
    request(tokens, policy = wait)
}
