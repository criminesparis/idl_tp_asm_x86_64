#include <stdio.h>
#include <inttypes.h>

int64_t fib_rec(int64_t);
int64_t fib_iter(int64_t);
int64_t fib_binet(int64_t);

int main() {
    // printf("%" PRId64 "\n", fib_iter(0));
    // printf("%" PRId64 "\n", fib_iter(1));
    // printf("%" PRId64 "\n", fib_iter(2));
    // printf("%" PRId64 "\n", fib_iter(5));

    printf("%" PRId64 "\n", fib_rec(0));
    printf("%" PRId64 "\n", fib_rec(9));
    printf("%" PRId64 "\n", fib_binet(0));
    printf("%" PRId64 "\n", fib_binet(1));
    printf("%" PRId64 "\n", fib_binet(9));
    return 0;
}
