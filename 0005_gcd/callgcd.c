#include <stdio.h>
#include <inttypes.h>

int64_t gcd(int64_t, int64_t);

int main() {
    printf("%" PRId64 "\n", gcd(41, 41));
    printf("%" PRId64 "\n", gcd(42, 1));
    printf("%" PRId64 "\n", gcd(25, 15));
    printf("%" PRId64 "\n", gcd(42, 35));
    return 0;
}
