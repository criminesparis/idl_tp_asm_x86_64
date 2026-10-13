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
    // compare x (x0) and y (x1), select max into x3
    cmp x0, x1
    csel x3, x0, x1, gt

    // compare z (x2) and max(x, y) (x3), select final max into x0
    cmp x2, x3
    csel x0, x2, x3, gt

    ret
