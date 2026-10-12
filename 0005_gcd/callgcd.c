#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

int64_t callgcd(int64_t x, int64_t y);

int main(int argc, char *argv[]) {
    if (argc >= 3) {
        int64_t x = atoll(argv[1]);
        int64_t y = atoll(argv[2]);
        printf("%" PRId64 "\n", callgcd(x, y));
        return 0;
    }

    printf("%" PRId64 "\n", callgcd(14, 189)); 
    printf("%" PRId64 "\n", callgcd(312, 27)); 

    return 0;
}