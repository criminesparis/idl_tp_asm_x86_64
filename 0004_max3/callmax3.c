#include <stdio.h>
#include <inttypes.h>
#define _POSIX_C_SOURCE 200809L
#include <stdlib.h>


int64_t max3(int64_t x, int64_t y, int64_t z);

int main(int argc, char *argv[]) {

    if (argc >= 4) {
        int64_t x = atoll(argv[1]);
        int64_t y = atoll(argv[2]);
        int64_t z = atoll(argv[3]);
        printf("%" PRId64 "\n", max3(x, y, z));
        return 0;
    }


    printf("%" PRId64 "\n", max3(x, y, z));
    printf("%" PRId64 "\n", max3(1, -4, -7));
    printf("%" PRId64 "\n", max3(2, -6, 1));
    printf("%" PRId64 "\n", max3(2, 3, 1));
    printf("%" PRId64 "\n", max3(-2, 4, 3));
    printf("%" PRId64 "\n", max3(2, -6, 7));
    printf("%" PRId64 "\n", max3(2, 4, 6));
    return 0;
}
