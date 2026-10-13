// int64_t fib_iterative(int64_t x)
// AArch64, convention AAPCS64: x -> x0, résultat dans x0.
// Indice: cmp puis csel (sélection conditionnelle), pas de branchement.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_iterative)
C(fib_iterative):
    // initialize fib(0) = 0 and fib(1) = 1
    movz x1, #0
    movz x2, #1

    // initialize loop counter i = 0
    movz x3, #0

    // check if n > 0 to enter loop
    cmp x0, x3 
    b.gt loop
    b loop_end

loop:
    // compute next term: x4 = x1 + x2
    add x4, x1, x2

    // shift values: x1 = x2, x2 = next
    mov x1, x2 
    mov x2, x4

    // increment counter and check if i < n
    add x3, x3, #1
    cmp x0, x3
    b.gt loop
    b loop_end

loop_end:
    // return fib(n) in x0
    mov x0, x1
    ret