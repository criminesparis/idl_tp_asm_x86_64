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
    // TODO
    cmp x0, x1 // fills the flag with x0 - x1 (I guess ?)
    csel x0, x0, x1, GT // x0 <- x0 if flag > 0, x1 else (I guess)
    cmp x0, x2 // same thing with x0 and x2 ...
    csel x0, x0, x2, GT
    ret
