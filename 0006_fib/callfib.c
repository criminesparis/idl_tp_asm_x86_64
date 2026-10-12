#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

int64_t callfib(int64_t n);

int main(int argc, char *argv[]) {
    if (argc >= 2) {
        int64_t n = atoll(argv[1]);
        printf("%" PRId64 "\n", callfib(n));
        return 0;
    }

    printf("%" PRId64 "\n", callfib(14)); 
    printf("%" PRId64 "\n", callfib(312)); 

    return 0;
}