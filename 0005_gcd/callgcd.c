#include <stdio.h>
#include <inttypes.h>

int64_t gcd(int64_t, int64_t);

int main() {
	printf("%" PRId64 "\n", gcd(120, 12));
	return 0;
}
