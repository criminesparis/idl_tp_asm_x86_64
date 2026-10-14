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

foo:
    cmp $2, %rdi
    jl .End

    dec %rdi
    push %rdi
    call foo
    pop %rdi

    push %rax

    dec %rdi
    push %rdi
    call foo
    pop %rdi
    
    pop %rbx
    add %rbx, %rax

.Retour:
    ret
.End:
    mov %rdi, %rax
    jmp .Retour
