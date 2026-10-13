#include <stdio.h>
#include <inttypes.h>

int64_t fib_binet(int64_t);

int main() {
    printf("%" PRId64 "\n", fib_binet(0));
    printf("%" PRId64 "\n", fib_binet(1));
    printf("%" PRId64 "\n", fib_binet(2));
    printf("%" PRId64 "\n", fib_binet(3));
    printf("%" PRId64 "\n", fib_binet(4));
    printf("%" PRId64 "\n", fib_binet(5));
    printf("%" PRId64 "\n", fib_binet(6));
    printf("%" PRId64 "\n", fib_binet(7));
    printf("%" PRId64 "\n", fib_binet(8));
    printf("%" PRId64 "\n", fib_binet(9));
    printf("%" PRId64 "\n", fib_binet(10));
    return 0;
}
