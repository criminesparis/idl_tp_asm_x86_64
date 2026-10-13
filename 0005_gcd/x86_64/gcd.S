#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)
C(gcd):
while:
    cmp         %rsi, %rdi
    je          end_while
    jl          b_lower_than_a
    sub         %rsi, %rdi
    jmp         while
b_lower_than_a:
    sub         %rdi, %rsi
    jmp         while
end_while:
    mov         %rdi, %rax
    ret