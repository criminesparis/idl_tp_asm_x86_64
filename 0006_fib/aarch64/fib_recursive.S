// int64_t fib_recursive(int64_t x)
// AArch64, convention AAPCS64: x -> x0, résultat dans x0.
// Indice: cmp puis csel (sélection conditionnelle), pas de branchement.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_recursive)
C(fib_recursive):
    b fib_rec

fib_rec:
    // base case: if n < 2, return n directly (fib(0) = 0, fib(1) = 1)
    cmp x0, #2
    b.lt base_case
    
    // save current n (x0) and link register lr (x30) before first recursive call
    stp x0, x30, [sp, #-16]!

    // compute fib(n - 1)
    sub x0, x0, #1
    bl fib_rec
    mov x1, x0

    // restore original n and link register
    ldp x0, x30, [sp], #16

    // save n, lr, and the result of fib(n - 1) (x1) before second recursive call
    stp x0, x30, [sp, #-16]!
    str x1, [sp, #-16]!

    // compute fib(n - 2)
    sub x0, x0, #2
    bl fib_rec
    mov x2, x0

    // restore fib(n - 1) into x1, then restore n and lr
    ldr x1, [sp], #16
    ldp x0, x30, [sp], #16

    // return fib(n - 1) + fib(n - 2) in x0
    add x0, x1, x2
    ret

base_case:
    // return n in x0
    ret