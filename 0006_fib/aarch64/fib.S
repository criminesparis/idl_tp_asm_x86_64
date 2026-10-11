.macro ADDR reg, sym
adrp    \reg, \sym@PAGE
add     \reg, \reg, \sym@PAGEOFF
.endm

// On définit une convention pour les appels de fonction.
// Lors d'un appel, on stock la pair (prev_lr, prev_fp)
// puis viennent les arguments et enfin l'output de la fonction.
// Lorsque foo finit, on restaure (prev_lr, prev_fp) et on met
// le résultat de la fonction dans le registre out.
// Utiliser CALL garde sp inchangé (on discard les cases mémoires
// auxiliaires utilisées)
.macro CALL foo, in, out
stp     xzr, \in, [sp, #-32]!
stp     x29, x30, [sp, #16]
add     x29, sp, #16
bl      \foo
ldp     x29, x30, [sp], #16
ldur    \out, [sp, #-32]
.endm

    .text
    .globl _main
_main:
    stp     x29, x30, [sp, #-32]!   // fp, lr
    stp     x19, x20, [sp, #16]     // callee-saved utilisés
    mov     x29, sp
    mov     w19, w0                 // w19 = argc
    mov     x20, x1                 // x20 = argv

    // vérifier nombre d'arguments
    cmp     w19, #3
    b.ne    err_args

    // load n et le flag
    ldr     x0, [x20, #8]
    bl      _atoi
    mov     w19, w0                 // x19 <- n
    ldr     x0, [x20, #16]
    bl      _atoi
    mov     w20, w0                 // x20 <- flag

    // branch sur version de fib
    cmp     x20, #0
    b.eq    rec
    cmp     x20, #1
    b.eq    iter
    cmp     x20, #2
    b.eq    binet

    // fib recursif, x19 contient le résultat
    rec:
        CALL    fn_rec, x19, x19
        b       end

        fn_rec:
            ldr     x0, [sp, #8]
            cmp     x0, #2
            b.lt    triv

            sub     x0, x0, #1
            CALL    fn_rec, x0, x1
            str     x1, [sp, #-8]!

            ldr     x0, [sp, #16] // reload n qui n'est pas préservé par fn_rec
            sub     x0, x0, #2
            CALL    fn_rec, x0, x1
            str     x1, [sp, #-8]!

            ldp     x0, x1, [sp], #16
            add     x0, x0, x1

            triv:
                str     x0, [sp]

            mov     sp, x29
            ret


    // fib itératif, x19 contient le résultat
    iter:
        mov     x9, #0              // a
        mov     x10, #1             // b
        cmp     x19, #0

        while:
            b.eq    end_iter

            mov     x11, x9         // temp_a
            mov     x9, x10         // a <- b
            add     x10, x9, x11    // b <- b + a

            subs     x19, x19, #1    // n--
            b       while

        end_iter:
            mov     x19, x9
            b       end

    // fib binet
    binet:
        mov     x0, #5
        scvtf   d0, x0
        bl      _sqrt
        fmov    d2, #1.0
        fadd    d1, d0, d2
        fmov    d3, #2.0
        fdiv    d1, d1, d3

        cmp     x19, 0
        while_binet:
            b.eq    end_binet
            fmul    d2, d2, d1
            subs     x19, x19, #1
            b       while_binet

        end_binet:
            fdiv    d2, d2, d0
            fcvtas  x19, d2


    end:
        ADDR    x0, msg
        str     w19, [sp, #-16]!
        bl      _printf
        add     sp, sp, #16

        mov     w0, #0
        ldp     x19, x20, [sp, #16]
        ldp     x29, x30, [sp], #32
        ret

    err_args:
        ADDR    x0, err_args_msg
        bl      _printf

        mov     w0, #1              // exit status code = 1
        ldp     x19, x20, [sp, #16]
        ldp     x29, x30, [sp], #32
        ret

.section __TEXT,__cstring
msg:
    .asciz  "%d\n"
err_args_msg:
    .asciz  "Error: incorrect number of argument.\n"
