# x86-64, syntaxe AT&T, convention System V: x -> %rdi, y -> %rsi, z -> %rdx,
# résultat dans %rax. Indice: cmp puis cmovl/cmovg (déplacement conditionnel).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_rec)
    .globl C(fib_iter)
    .globl C(fib_binet)
    .globl C(pow)


C(fib_rec):
    cmp $2, %rdi
    jl init_fib


    push %rdi
    push %rsi


    dec %rdi
    call fib_rec
    mov %rax, %rsi

    dec %rdi
    call fib_rec
    add %rsi, %rax

    pop %rsi
    pop %rdi

    ret
    
    init_fib:
    mov %rdi, %rax
    ret



C(fib_iter):
    mov %rdi, %rbp
    mov $0, %rax
    mov $1, %rdx


    start_loop:
    cmp $0, %rdi
    jle end_loop

    mov %rdx, %rsi
    add %rax, %rdx
    mov %rsi, %rax

    dec %rdi
    
    jmp start_loop

    end_loop:
    ret



C(fib_binet):
    mov $5, %rdx
    cvtsi2sd %rdx, %xmm0

    sqrtsd %xmm0, %xmm0
 #   sqrtsd %xmm0, %xmm3 #sqrt(5)
    

    mov $1, %rdx
    cvtsi2sd %rdx, %xmm1
    cvtsi2sd %rdx, %xmm2 #1.
    addsd %xmm1, %xmm0

    mov $2, %rdx
    cvtsi2sd %rdx, %xmm1
    divsd %xmm1, %xmm0



    start_pow:
    cmp $0, %rdi
    je end_pow

    mulsd %xmm0, %xmm2
    dec %rdi
    jmp start_pow

    end_pow:
    mov $5, %rdx
    cvtsi2sd %rdx, %xmm0

    sqrtsd %xmm0, %xmm0
    divsd %xmm0, %xmm2

    cvtsd2si  %xmm2, %rax
    ret















