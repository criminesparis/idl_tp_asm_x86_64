#include <stdio.h>
#include <inttypes.h>

int64_t max3(int64_t, int64_t, int64_t);

int main() {
    printf("%" PRId64 "\n", max3(1, -4, -7));
    printf("%" PRId64 "\n", max3(2, -6, 1));
    printf("%" PRId64 "\n", max3(2, 3, 1));
    printf("%" PRId64 "\n", max3(-2, 4, 3));
    printf("%" PRId64 "\n", max3(2, -6, 5));
    printf("%" PRId64 "\n", max3(2, 4, 6));
    return 0;
}
