# int64_t max3(int64_t x, int64_t y, int64_t z)
# x86-64, syntaxe AT&T, convention System V: x -> %rdi, y -> %rsi, z -> %rdx,
# résultat dans %rax. Indice: cmp puis cmovl/cmovg (déplacement conditionnel).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)
C(gcd):
    # TODO
    loop_start:

    cmp %rsi, %rdi
    je end_loop
    jg rdi_bigger

    sub %rdi, %rsi
    jmp loop_start

    rdi_bigger:
    sub %rsi, %rdi


    cmp %rsi, %rdi
    jne loop_start

    end_loop:
    mov %rdi, %rax
    ret
