#include <stdio.h>
#include <inttypes.h>

int64_t fibrec(int64_t);
int64_t fibiter(int64_t);
int64_t fibinet(int64_t);


int main() {
	printf("Calling with rec fib(6) : %" PRId64 "\n", fibrec(6));
	printf("Calling with iter fib(6) : %" PRId64 "\n", fibiter(6));
	printf("Calling with binet fib(6) : %" PRId64 "\n", fibiter(6));
	return 0;
}
