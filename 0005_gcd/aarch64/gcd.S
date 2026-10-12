.macro ADDR reg, sym
adrp    \reg, \sym@PAGE
add     \reg, \reg, \sym@PAGEOFF
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

    // load les arguments
    ldr     x0, [x20, #8]
    bl      _atoi
    mov     w19, w0
    ldr     x0, [x20, #16]
    bl      _atoi
    mov     w20, w0

    // traiter le cas a = 0 ou b = 0
    cmp     x19, #0
    b.eq    end
    cmp     x20, #0
    b.eq    end_b0

    while:
        cmp x19, x20
        b.eq end

        cmp     x19, x20
        b.le    a_smaller

        sub     x19, x19, x20
        b       while

        a_smaller:
            sub x20, x20, x19
            b   while

    end_b0:
        mov     x19, x20
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
