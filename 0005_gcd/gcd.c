#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t gcd(int64_t a, int64_t b);

int main(int argc, char *argv[]) {
    if (argc != 3){
        fprintf(stderr, "Usage %s A B \n", argv[0]);
        return 1;
    }

    int64_t a = strtoll(argv[1], NULL, 10);
    int64_t b = strtoll(argv[2], NULL, 10);

    int64_t result = gcd(a, b);

    printf("%lld\n", result);
    return 0;
}