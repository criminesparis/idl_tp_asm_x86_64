#include <stdio.h>
#include <inttypes.h>

int64_t fibo_lineaire(int64_t);
int64_t fibo_recursif(int64_t);
int64_t fibo_binet(int64_t);

int main() {
    printf("%" PRId64 "\n", fibo_lineaire(0));
    printf("%" PRId64 "\n", fibo_lineaire(1));
    printf("%" PRId64 "\n", fibo_lineaire(2));
    printf("%" PRId64 "\n", fibo_lineaire(3));
    printf("%" PRId64 "\n", fibo_recursif(4));
    printf("%" PRId64 "\n", fibo_recursif(5));
    printf("%" PRId64 "\n", fibo_recursif(6));
    printf("%" PRId64 "\n", fibo_binet(3));
    printf("%" PRId64 "\n", fibo_binet(4));
    printf("%" PRId64 "\n", fibo_binet(5));
    return 0;
}
