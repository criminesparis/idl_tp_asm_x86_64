#include <stdio.h>
#include <inttypes.h>

int64_t fib(int64_t);

int main() {
    printf("%" PRId64 "\n", fib(0));
    printf("%" PRId64 "\n", fib(1));
    printf("%" PRId64 "\n", fib(2));
    printf("%" PRId64 "\n", fib(3));
    printf("%" PRId64 "\n", fib(4));
    printf("%" PRId64 "\n", fib(5));
    printf("%" PRId64 "\n", fib(6));
    printf("%" PRId64 "\n", fib(7));
    printf("%" PRId64 "\n", fib(8));
    printf("%" PRId64 "\n", fib(9));
    printf("%" PRId64 "\n", fib(10));
    return 0;
}
