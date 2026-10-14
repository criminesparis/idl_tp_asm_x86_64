#include <stdio.h>
#include <inttypes.h>

int64_t gcd(int64_t, int64_t);

int main() {
    printf("%" PRId64 "\n", gcd(1, 4));
    printf("%" PRId64 "\n", gcd(2, 6));
    printf("%" PRId64 "\n", gcd(3, 6));
    printf("%" PRId64 "\n", gcd(5, 25));
    return 0;
}
