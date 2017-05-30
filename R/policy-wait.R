wait <- function(tokens, exception) {
    pause(exception$wait_time)
    request(tokens, policy = wait)
}

pause <- function(wait_time) {
    Sys.sleep(wait_time + .02)
}
