condition <- function(subclass, message, call = sys.call(-1), ...) {
    structure(
        class = c(subclass, "condition"),
        list(message = message, call = call, ...)
    )
}

rate_limit_exception <- function(wait_time) {
    condition("rate_limit_exception",
              message = "",
              call = NULL,
              wait_time = wait_time)
}
