#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_iter)
C(fib_iter):
fibonacci:
    mov         $1, %r12 # a
    mov         $0, %rax # b
    mov         $0, %r13 # c
while:
    cmp         $1, %rdi
    jl          return
    dec         %rdi
    mov         %rax, %r13
    add         %r12, %r13
    mov         %rax, %r12
    mov         %r13, %rax
    jmp         while
return:
    ret          