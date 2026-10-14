# int64_t max3(int64_t x, int64_t y, int64_t z)
# x86-64, syntaxe AT&T, convention System V: n -> %rdi
# résultat dans %rax. Indice: cmp puis cmovl/cmovg (déplacement conditionnel).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fibo_binet)
    .globl C(fibo_recursif)
    .globl C(fibo_lineaire)

C(fibo_binet): #fibo binet
    # TODO

    mov $5, %rbx
    cvtsi2sd %rbx, %xmm0
    sqrtsd %xmm0, %xmm0
    movsd %xmm0, %xmm2  #sqrt 5 -> xmm2
    mov $1, %rbx
    cvtsi2sd %rbx, %xmm1
    addsd %xmm1, %xmm0
    mov $2, %rbx
    cvtsi2sd %rbx, %xmm1
    divsd %xmm1 , %xmm0  #phi -> xmm0

    mov $1, %rbx
    cvtsi2sd %rbx, %xmm1

    cmp $0, %rdi
    je .End1

.BeginFor1:
    mulsd %xmm0, %xmm1
    
    dec %rdi
    cmp $0, %rdi
    jne .BeginFor1
.End1:
    divsd %xmm2, %xmm1
    cvtsd2si %xmm1, %rax
    
    ret


C(fibo_recursif):
    # TODO

foo:
    cmp $2, %rdi
    jl .End2

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

.Retour2:
    ret
.End2:
    mov %rdi, %rax
    jmp .Retour2

C(fibo_lineaire):
    # TODO
    mov $0, %rbx   #a
    mov $1, %rcx   #b

    cmp $0, %rdi
    je .End3

.BeginFor3:
    mov %rbx, %rsi #a -> tmp
    mov %rcx, %rbx #b -> a
    add %rsi, %rcx # b+tmp ->b
    

    dec %rdi
    cmp $0, %rdi
    jne .BeginFor3
.End3:
    mov %rbx, %rax

    ret
