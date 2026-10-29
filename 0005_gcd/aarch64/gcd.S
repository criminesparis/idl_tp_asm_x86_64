// int64_t gcd(int64_t x0, int64_t x1)


#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)

C(gcd):
    loop_start:
        cmp x0, x1
        b.eq loop_end
        b.gt sub_x0
        b.lt sub_x1
        b loop_start

    loop_end:
        ret

    sub_x0:
        sub x0, x0, x1
        b loop_start

    sub_x1: 
        sub x1, x1, x0
        b loop_start

