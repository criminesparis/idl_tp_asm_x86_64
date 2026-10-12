# int64_t callfib(int64_t x, int64_t y)
# x86-64, syntaxe AT&T, convention System V: n -> %rdi
# résultat dans %rax.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text


    .globl C(fib_rec)
C(fib_rec):
    cmpq    $1, %rdi
    jle     .Lfib_rec_base

    pushq   %rbx            
    pushq   %rdi            

    decq    %rdi             
    call    C(fib_rec)
    movq    %rax, %rbx       # %rbx = fib_rec(n - 1)

    movq    (%rsp), %rdi    
    subq    $2, %rdi        
    call    C(fib_rec)

    addq    %rbx, %rax       # %rax = fib_rec(n - 1) + fib_rec(n - 2)

    popq    %rdi
    popq    %rbx
    ret

.Lfib_rec_base:
    movq    %rdi, %rax
    ret



    .globl C(fib_iter)
C(fib_iter):
    movq    $0, %rax         # a = 0
    movq    $1, %rsi         # b = 1

.Liter_loop:
    testq   %rdi, %rdi
    jz      .Liter_end

    movq    %rsi, %rcx       # tmp = b
    addq    %rax, %rsi       # b = a + b
    movq    %rcx, %rax       # a = tmp

    decq    %rdi
    jmp     .Liter_loop

.Liter_end:
    ret



    .globl C(fib_binet)
C(fib_binet):
    pushq   %rbx
    subq    $8, %rsp          # Alignement de la pile à 16 octets

    movq    %rdi, %rbx       

    # Calculer sqrt(5.0)
    movsd   .Lconst_5(%rip), %xmm0
    sqrtsd  %xmm0, %xmm0      
    movsd   %xmm0, %xmm2      

    # Calculer phi = (1.0 + sqrt(5.0)) / 2.0
    addsd   .Lconst_1(%rip), %xmm0          # %xmm0 = 1.0 + sqrt(5.0)
    divsd   .Lconst_2(%rip), %xmm0          # %xmm0 = phi

    # Calculer phi^n via pow(phi, (double)n)
    cvtsi2sd %rbx, %xmm1      

    call    C(pow)           

    # Calculer F(n) = round( phi^n / sqrt(5.0) )
    divsd   %xmm2, %xmm0      # %xmm0 = phi^n / sqrt(5.0)
    call    C(round)         


    cvttsd2si %xmm0, %rax

    addq    $8, %rsp
    popq    %rbx
    ret

# Section des données constantes flottantes
    .section .rodata
.Lconst_1:
    .double 1.0
.Lconst_2:
    .double 2.0
.Lconst_5:
    .double 5.0

.section .note.GNU-stack,"",@progbits