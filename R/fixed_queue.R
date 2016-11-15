fixed_queue <- function(n) {
    # not quite a queue, but a data structure that is like a queue but is
    # always expected to have the same size.

    # create by fixing a numeric vector and then moving the pointer to define
    # the "front" (for popping) and "back" (for pushing) of the queue
    fq <- vector("numeric", length = n)
    front_ptr <- 1L
    back_ptr <- 1L

    push <- function(number) {
        # push new entries to the back
        fq[back_ptr] <<- number

        # and then update the pointer to the new "back" of the queue
        if (back_ptr >= n)
            back_ptr <<- 1L
        else back_ptr <<- back_ptr + 1L
    }

    front <- function() fq[[front_ptr]]

    pop <- function() {
        # update the front pointer to the new "front" of the queue
        if (front_ptr >= n)
            front_ptr <<- 1L
        else front_ptr <<- front_ptr + 1L
    }

    function(op)
        switch(
            op,
            front = function() front(),
            push = function(num) push(num),
            pop = function() pop())
}

push <- function(fq, num) fq("push")(num)
pop <- function(fq) fq("pop")()
front <- function(fq) fq("front")()
