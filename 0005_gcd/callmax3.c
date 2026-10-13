#include <inttypes.h>
#include <stdio.h>

int64_t gcd(int64_t, int64_t);

int main() {
  printf("%" PRId64 "\n", gcd(1, 4));
  printf("%" PRId64 "\n", gcd(2, 6));
  printf("%" PRId64 "\n", gcd(2, 1));
  printf("%" PRId64 "\n", gcd(4, 3));
  printf("%" PRId64 "\n", gcd(2, 5));
  printf("%" PRId64 "\n", gcd(3, 6));
  return 0;
}
