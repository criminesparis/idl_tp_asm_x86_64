#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)

C(pgd):
    push %r12
    push %r13

loop:
    cmp %rsi, %rdi
    je end

    jg soustrab
    jl soustrba

soustrab:
    sub %rsi, %rdi
    jmp loop

soustrba:
    sub %rdi, %rsi
    jmp loop

end:
    mov %rdi, %rax

    pop %r13
    pop %r12
    ret


C(main):
    push %rbx
    push %r12
    push %r13

    mov %rsi, %rbx

    mov 8(%rbx), %rdi
    call C(atoi)
    movslq %eax, %r12

    mov 16(%rbx), %rdi
    call C(atoi)
    movslq %eax, %r13

    mov %r12, %rdi
    mov %r13, %rsi
    call C(pgd)

    mov %eax, %esi
    leaq format(%rip), %rdi
    xor %eax, %eax
    call C(printf)

    pop %r13
    pop %r12
    pop %rbx

    xor %eax, %eax
    ret


    .section .rodata
format:
    .string "%d\n"