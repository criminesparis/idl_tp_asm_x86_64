// int64_t gcd(int64_t x, int64_t y)
// AArch64, convention AAPCS64: x -> x0, y -> x1, résultat dans x0.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)
C(gcd):
    there:
        cmp x0, x1
        bgt x0_greater
        blt x1_greater
        b end

    x0_greater:
        sub x0, x0, x1
        b there

    x1_greater:
        sub x1, x1, x0
        b there

    end:
        ret
