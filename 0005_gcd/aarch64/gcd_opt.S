// int64_t gcd_opt(int64_t x0, int64_t x1)
// This code is an more optimized version of gcd. The gcd code was my first try, this one has been done after some research and AI use

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd_opt)

C(gcd_opt):
    loop_start:
        cmp x0, x1
        b.eq loop_end
        b.gt sub_x0
        sub x1, x1, x0
        b loop_start

    loop_end:
        ret

    sub_x0:
        sub x0, x0, x1
        b loop_start



