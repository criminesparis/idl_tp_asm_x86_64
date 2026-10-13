// #include <inttypes.h>
// #include <stdio.h>

// // int64_t fib_recursive(int64_t);
// int64_t fib_iterative(int64_t);
// int64_t fib_binet(int64_t);

// int main() {
//   // printf("%" PRId64 "\n", fib_recursive(5));
//   // printf("%" PRId64 "\n", fib_recursive(10));
//   printf("%" PRId64 "\n", fib_iterative(5));
//   printf("%" PRId64 "\n", fib_iterative(10));
//   printf("%" PRId64 "\n", fib_binet(0));
//   printf("%" PRId64 "\n", fib_binet(1));
//   printf("%" PRId64 "\n", fib_binet(2));
//   printf("%" PRId64 "\n", fib_binet(3));
//   printf("%" PRId64 "\n", fib_binet(4));
//   printf("%" PRId64 "\n", fib_binet(5));
//   printf("%" PRId64 "\n", fib_binet(10));
//   return 0;
// }

#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>

// Assembly implementations
int64_t fib_recursive(int64_t);
int64_t fib_iterative(int64_t);
int64_t fib_binet(int64_t);

typedef struct {
  int64_t input;
  int64_t expected;
} TestCase;

static const TestCase tests[] = {
    {0, 0},  {1, 1},  {2, 1},  {3, 2},   {4, 3},    {5, 5},     {6, 8},
    {7, 13}, {8, 21}, {9, 34}, {10, 55}, {15, 610}, {20, 6765}, {30, 832040}};

typedef int64_t (*FibFunction)(int64_t);

typedef struct {
  const char *name;
  FibFunction function;
} Implementation;

static const Implementation implementations[] = {
    {"Iterative", fib_iterative},
    {"Binet", fib_binet},
    {"Recursive", fib_recursive},
};

int main(void) {
  int global_passed = 0;
  int global_total = 0;

  const size_t test_count = sizeof(tests) / sizeof(tests[0]);
  const size_t implementation_count =
      sizeof(implementations) / sizeof(implementations[0]);

  for (size_t i = 0; i < implementation_count; i++) {
    const Implementation *impl = &implementations[i];

    int passed = 0;
    int failed = 0;

    printf("\n=== %s ===\n", impl->name);

    for (size_t j = 0; j < test_count; j++) {
      int64_t actual = impl->function(tests[j].input);
      bool success = actual == tests[j].expected;

      if (success) {
        passed++;
        printf("[OK]   fib(%" PRId64 ") = %" PRId64 "\n", tests[j].input,
               actual);
      } else {
        failed++;
        printf("[FAIL] fib(%" PRId64 ") = %" PRId64 " | expected: %" PRId64
               "\n",
               tests[j].input, actual, tests[j].expected);
      }
    }

    global_passed += passed;
    global_total += (int)test_count;

    printf("\n--- %s SUMMARY ---\n", impl->name);
    printf("Passed:       %d/%zu\n", passed, test_count);
    printf("Failed:       %d\n", failed);
    printf("Success rate: %.1f%%\n", 100.0 * passed / test_count);
  }

  printf("\n=== GLOBAL SUMMARY ===\n");
  printf("Passed: %d/%d\n", global_passed, global_total);
  printf("Failed: %d\n", global_total - global_passed);
  printf("Success rate: %.1f%%\n",
         global_total ? 100.0 * global_passed / global_total : 0.0);

  return global_passed == global_total ? 0 : 1;
}
