#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t fib_binet(int64_t n);

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s N\n", argv[0]);
        return 1;
    }

    int64_t n = strtoll(argv[1], NULL, 10);
    if (n < 0) {
        fprintf(stderr, "N must be non-negative\n");
        return 1;
    }

    printf("%" PRId64 "\n", fib_binet(n));
    return 0;
}
