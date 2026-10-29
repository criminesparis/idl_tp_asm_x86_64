// int64_t fib_binet(int64_t x0)
// dans celui là je me suis amusé à tenter d'utiliser les forward and backward (f and b)


#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .p2align 2
    .globl C(fib_binet)

C(fib_binet):
    mov     x1, #5
    scvtf   d1, x1
    fsqrt   d1, d1

    fmov    d2, #1.0
    fadd    d0, d2, d1
    fmov    d3, #2.0
    fdiv    d0, d0, d3

    fmov    d2, #1.0
    cmp     x0, #0
    b.eq    2f

    1:
        fmul    d2, d2, d0
        subs    x0, x0, #1
        b.ne    1b

    2:
        fdiv    d2, d2, d1

        fcvtns  x0, d2
        ret  