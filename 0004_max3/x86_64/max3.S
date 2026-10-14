# int64_t max3(int64_t x, int64_t y, int64_t z)
# x86-64, syntaxe AT&T, convention System V: x -> %rdi, y -> %rsi, z -> %rdx,
# résultat dans %rax. Indice: cmp puis cmovl/cmovg (déplacement conditionnel).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(max3)
C(max3):
    cmp     %rsi, %rdi
    cmovg   %rdi, %rax
    cmovl   %rsi, %rax
    cmp     %rdx, %rax
    cmovl   %rdx, %rax
    ret
