// int64_t gcd(int64_t x, int64_t y)
// AArch64, convention AAPCS64: x -> x0, y -> x1, résultat dans x0.
// Indice: cmp puis csel (sélection conditionnelle), pas de branchement.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)
C(gcd):
    // check if x and y are equal at start
    cmp x0, x1
    b.ne loop_start
    b.eq loop_end

loop_start:
    // determine which value is strictly greater
    cmp x0, x1
    b.gt if_positive
    b.le else_case

loop_end:
    // return with result in x0
    ret

if_positive:
    // x > y: compute x = x - y
    sub x2, x0, x1
    mov x0, x2
    cmp x0, x1
    b.ne loop_start
    b.eq loop_end

else_case:
    // y >= x: compute y = y - x
    sub x2, x1, x0
    mov x1, x2
    cmp x0, x1
    b.ne loop_start
    b.eq loop_end