#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

int64_t max3(int64_t, int64_t, int64_t);

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s a b c\n", argv[0]);
        return 1;
    }

    int64_t a = strtoll(argv[1], NULL, 10);
    int64_t b = strtoll(argv[2], NULL, 10);
    int64_t c = strtoll(argv[3], NULL, 10);

    int64_t result = max3(a, b, c);

    printf("%" PRId64 "\n", result);

    return 0;
}