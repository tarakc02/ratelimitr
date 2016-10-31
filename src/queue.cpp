#include <Rcpp.h>
#include <queue>
using namespace Rcpp;

typedef std::queue<double> queue; // convenience typedef

void q_push( queue* obj, double x) { obj->push( x ); }
void q_pop( queue* obj ) { obj->pop( ); }

double q_back(queue *obj){ return obj->back() ; }
double q_front(queue *obj){ return obj->front() ; }


RCPP_MODULE(mod_queue) {
    using namespace Rcpp;
    // expose the class std::queue<double> as "queue" on the R side
    class_<queue>( "queue")
        // exposing constructors
        .constructor()

        // exposing member functions
        .method( "size", &queue::size )
        .method( "empty", &queue::empty )
        .method( "push", &q_push )
        .method( "pop", &q_pop )

        // specifically exposing const member functions
        .method( "back", &q_back )
        .method( "front", &q_front )
        ;
}
