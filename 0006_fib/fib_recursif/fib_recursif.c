#include <stdio.h>
#include <inttypes.h>

int64_t fib_recursif(int64_t);

int main() {
    printf("%" PRId64 "\n", fib_recursif(0));
    printf("%" PRId64 "\n", fib_recursif(1));
    printf("%" PRId64 "\n", fib_recursif(2));
    printf("%" PRId64 "\n", fib_recursif(3));
    printf("%" PRId64 "\n", fib_recursif(4));
    printf("%" PRId64 "\n", fib_recursif(5));
    printf("%" PRId64 "\n", fib_recursif(6));
    printf("%" PRId64 "\n", fib_recursif(7));
    printf("%" PRId64 "\n", fib_recursif(8));
    printf("%" PRId64 "\n", fib_recursif(9));
    printf("%" PRId64 "\n", fib_recursif(10));
    return 0;
}
