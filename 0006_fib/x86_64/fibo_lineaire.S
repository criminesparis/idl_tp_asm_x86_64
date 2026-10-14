# int64_t max3(int64_t x, int64_t y, int64_t z)
# x86-64, syntaxe AT&T, convention System V: n -> %rdi
# résultat dans %rax. Indice: cmp puis cmovl/cmovg (déplacement conditionnel).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fibo)
C(fibo):
    # TODO
    mov $0, %rbx   #a
    mov $1, %rcx   #b

    cmp $0, %rdi
    je .End

.BeginFor:
    mov %rbx, %rsi #a -> tmp
    mov %rcx, %rbx #b -> a
    add %rsi, %rcx # b+tmp ->b
    

    dec %rdi
    cmp $0, %rdi
    jne .BeginFor
.End:
    mov %rbx, %rax

    ret
