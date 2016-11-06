function_list <- function(...) {
    flist <- list(...)

    if (!all(vapply(flist, is.function, FUN.VALUE = logical(1))))
        stop("Invalid function")

    function_names <- names(flist)
    if (length(function_names) != length(flist))
        stop("Each function in a list of functions must be named")
    tryCatch(
        lapply(function_names, as.name),
        error = function(e) stop("Arguments to function_list must have valid names")
    )
    structure(flist,
              class = "function_list")
}
