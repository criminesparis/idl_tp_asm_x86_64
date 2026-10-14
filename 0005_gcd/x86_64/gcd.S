# int64_t max3(int64_t x, int64_t y, int64_t z)
# x86-64, syntaxe AT&T, convention System V: a -> %rdi, b -> %rsi, z -> %rdx,
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
    cmp %rdi, %rsi
    je .End
.BeginWhile:
    cmp %rdi, %rsi  # compare a et b
    jg .Then

    mov %rsi, %rcx
    sub %rcx, %rdi
    mov %rcx, %rsi
    jmp .EndIf
.Then:

    mov %rdi, %rbx
    sub %rbx, %rsi
    mov %rbx, %rdi
.EndIf:
    cmp %rdi, %rsi
    jne .BeginWhile
.End:
    mov %rdi, %rax

    ret
