#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_binet)
C(fib_binet):
fibonacci:
    cmp         $0, %rdi
    jle         zero
    mov         $1, %r12
    CVTSI2SD    %r12, %xmm0
    mov         $2, %r12    
    CVTSI2SD    %r12, %xmm1
    mov         $5, %r12    
    CVTSI2SD    %r12, %xmm2

    sqrtsd      %xmm2, %xmm2
    addsd       %xmm0, %xmm2
    divsd       %xmm1, %xmm2
    movsd       %xmm2, %xmm0

for:
    cmp         $1, %rdi
    jle         end_for
    dec         %rdi
    mulsd       %xmm0, %xmm2
    jmp         for

end_for:
    mov         $5, %r12    
    CVTSI2SD    %r12, %xmm0
    sqrtsd      %xmm0, %xmm0
    divsd       %xmm0, %xmm2
    CVTSD2SI    %xmm2, %rax
    ret
zero:
    mov         $0, %rax
    ret