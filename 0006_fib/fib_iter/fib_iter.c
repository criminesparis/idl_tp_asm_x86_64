#include <stdio.h>
#include <inttypes.h>

int64_t fib_iter(int64_t);

int main() {
    printf("%" PRId64 "\n", fib_iter(0));
    printf("%" PRId64 "\n", fib_iter(1));
    printf("%" PRId64 "\n", fib_iter(2));
    printf("%" PRId64 "\n", fib_iter(3));
    printf("%" PRId64 "\n", fib_iter(4));
    printf("%" PRId64 "\n", fib_iter(5));
    printf("%" PRId64 "\n", fib_iter(6));
    printf("%" PRId64 "\n", fib_iter(7));
    printf("%" PRId64 "\n", fib_iter(8));
    printf("%" PRId64 "\n", fib_iter(9));
    printf("%" PRId64 "\n", fib_iter(10));
    return 0;
}
