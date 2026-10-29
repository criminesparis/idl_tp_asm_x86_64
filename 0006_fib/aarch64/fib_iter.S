// int64_t fib_rec(int64_t x0)


#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .p2align 2
    .globl C(fib_iter)

C(fib_iter):
    mov     x1, #0
    mov     x2, #1

    cbz     x0, loop_end

    .p2align 2
loop_start:
    add     x3, x1, x2
    mov     x1, x2
    mov     x2, x3

    subs    x0, x0, #1
    b.ne    loop_start

    .p2align 2
loop_end:
    mov     x0, x1
    ret