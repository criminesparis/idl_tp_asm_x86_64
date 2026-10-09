#include <stdio.h>
#include <inttypes.h>

int64_t gcd(int64_t, int64_t);

int main() {
    printf("%" PRId64 "\n", gcd(5, 5));
    printf("%" PRId64 "\n", gcd(2, 2));
    printf("%" PRId64 "\n", gcd(10, 5));
    printf("%" PRId64 "\n", gcd(15, 5));
    printf("%" PRId64 "\n", gcd(15, 3));
    printf("%" PRId64 "\n", gcd(42, 600));
    return 0;
}
