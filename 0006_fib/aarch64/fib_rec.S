// int64_t fib_rec(int64_t x0)


#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .p2align 2
    .globl C(fib_rec)

C(fib_rec):
    cmp x0, #1
    b.gt recurse
    
    ret

    .p2align 2
recurse:
        stp x29, x30, [sp, #-32]!
        mov x29, sp
        str x0, [sp, #16]

        sub x0, x0, #1
        bl C(fib_rec)

        str x0, [sp, #24]

        ldr x0, [sp, #16]
        sub x0, x0, #2
        bl C(fib_rec)

        ldr x1, [sp, #24]
        add x0, x0, x1

        ldp x29, x30, [sp], #32
        ret