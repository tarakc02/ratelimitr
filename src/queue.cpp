#include <Rcpp.h>
#include <queue>
using namespace Rcpp;

typedef std::queue<double> queue; // convenience typedef

RCPP_MODULE(mod_queue) {
    using namespace Rcpp;
    // expose the class std::queue<double> as "queue" on the R side
    class_<queue>( "queue")
        // exposing constructors
        .constructor()

        // exposing member functions
        .method( "size", &queue::size )
        .method( "empty", &queue::empty )
        .method( "push", &queue::push )
        .method( "pop", &queue::pop )

        // specifically exposing const member functions
        .const_method( "back", &queue::back )
        .const_method( "front", &queue::front )
        ;
}
