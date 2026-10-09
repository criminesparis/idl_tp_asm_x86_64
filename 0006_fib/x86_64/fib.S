#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib)
C(fib):
fibonacci:
    cmp         $2, %rdi
    jl          n_lower_than_2

    push        %rdi
    dec         %rdi
    call        fibonacci
    pop         %rdi
    mov         %rax, %r12

    push        %r12

    sub         $2, %rdi
    call        fibonacci

    pop         %r12
    add         %r12, %rax
    ret
n_lower_than_2:
    mov         %rdi, %rax
    ret          