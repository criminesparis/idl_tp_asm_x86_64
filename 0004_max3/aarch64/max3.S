// int64_t max3(int64_t x, int64_t y, int64_t z)
// AArch64, convention AAPCS64: x -> x0, y -> x1, z -> x2, résultat dans x0.
// Indice: cmp puis csel (sélection conditionnelle), pas de branchement.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(max3)
C(max3):
    cmp x0, x1
    csel x0, x0, x1, ge
    cmp x0, x2
    csel x0, x0, x2, ge
    ret
