#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)

C(fib_iter):
    push %r12
    push %r13
    push %r14
    push %r15
    push %r10
    mov $0, %r13
    mov $1, %r14
    mov $0, %r15

loop:
    cmp %r15, %rdi
    je end

    mov %r14, %r10
    add %r13, %r14
    mov %r10, %r13
    add $1, %r15
    jmp loop

end:
    mov %r13, %rax
    pop %r10
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    ret

C(fib_rec):
    push %rbx
    push %r12
    push %rcx

    cmp $2, %rdi
    jl rend

    sub $1, %rdi
    mov %rdi, %rcx
    call C(fib_rec)
    mov %eax, %ebx
    sub $1, %rcx
    mov %rcx, %rdi
    call C(fib_rec)
    add %eax, %ebx
    mov %ebx, %eax

    pop %rcx
    pop %r12
    pop %rbx
    ret
    
rend: 
    mov %rdi, %rax
    pop %rcx
    pop %r12
    pop %rbx
    ret

C(fib_binet):
    push %rbx
    mov %rdi, %rbx

    mov $1, %eax
    cvtsi2sdl %eax, %xmm0
    mov $5, %eax
    cvtsi2sdl %eax, %xmm2
    sqrtsd %xmm2, %xmm2

    sub $8, %rsp
    movsd %xmm2, (%rsp)

    mov $2, %eax
    cvtsi2sdl %eax, %xmm3

    addsd %xmm2, %xmm0
    divsd %xmm3, %xmm0
    cvtsi2sdl %ebx, %xmm1

    call C(pow)

    movsd (%rsp), %xmm2
    add $8, %rsp

    divsd %xmm2, %xmm0

    roundsd $0, %xmm0, %xmm0
    cvttsd2si %xmm0, %eax

    pop %rbx
    ret

C(main):
    push %rbx
    push %r12

    mov %rsi, %rbx

    mov 8(%rbx), %rdi
    call C(atoi)
    movslq %eax, %r12

    # Appel de fib_iter
    mov %r12, %rdi
    call C(fib_iter)

    mov %eax, %esi
    leaq format(%rip), %rdi
    xor %eax, %eax
    call C(printf)

    # Appel de fib_rec
    mov %r12, %rdi
    call C(fib_rec)

    mov %eax, %esi
    leaq format(%rip), %rdi
    xor %eax, %eax
    call C(printf)

    # Appel de fib_binet
    mov %r12, %rdi
    call C(fib_binet)

    mov %eax, %esi
    leaq format(%rip), %rdi
    xor %eax, %eax
    call C(printf)

    pop %r12
    pop %rbx

    xor %eax, %eax
    ret


    .section .rodata
format:
    .string "%d\n"