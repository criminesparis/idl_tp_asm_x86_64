#define W        30
#define H        20
#define W_INIT   W / 2
#define H_INIT   H / 2
#define ORIGIN_Y 1
#define MAX_LEN  (W * H)
#define TICK0_MS 150
#define TICK_MIN 60

#define __FIXED_APPLE__ 0

// dst <- l[i]
.macro LOAD_BYTE dst, l, i, aux
    add     \aux, \l, \i
    ldrb    \dst, [\aux]
.endm

// dst <- x mod m (utilisant aux)
.macro MOD dst, x, m, aux
     udiv    \aux, \x, \m
     msub    \dst, \aux, \m, \x   // dst = x - (x / m) * m
.endm

// bl preserving lr
.macro CALL foo
    str     x30, [sp, #-16]!
    bl      \foo
    ldr     x30, [sp], #16
.endm

    .text
    .globl _main
_main:
    stp     x29, x30, [sp, #-96]!
    stp     x27, x28, [sp, #80]
    stp     x25, x26, [sp, #64]
    stp     x23, x24, [sp, #48]
    stp     x21, x22, [sp, #32]
    stp     x19, x20, [sp, #16]

    mov     x29, sp

    b       main_body
    // ┌───────────────────────────┐
    // │        FONCTIONS          │
    // └───────────────────────────┘

    // INITIALISATION DES VARIABLES
    init:

        // J'ai fais le choix d'un array de byte au lien d'un array de int (8 bytes)
        // Première raison: un int est très gros par rapport à des coordonnées sur un écran
        // Seconde raison: sub ne prend que des imm < 4096 (immediate values de 12bits seulement)
        // Donc ça peut coincer lorsque H*W > 4095 ou que H > 255 ou que W > 255.
        sub     sp, sp, #MAX_LEN
        mov     x19, sp                 // x19: pointeur vers bx
        sub     sp, sp, #MAX_LEN
        mov     x20, sp                 // x20: pointeur vers by
        mov     x21, #1                 // x21: dx
        mov     x22, #0                 // x22: dy
        mov     x23, #1                 // x22: len
        mov     x24, #3                 // x24: ax
        mov     x25, #3                 // x25: ay
        mov     x26, #0                 // x26: head
        mov     x27, #0                 // x27: tail
        mov     x0, #W_INIT
        strb    w0, [x19]               // bx[0] = W_INIT
        mov     x0, #H_INIT
        strb    w0, [x20]               // by[0] = H_INIT

        ret


    // FONCTION `ON_BODY`
    // INPUTS: (x0, x1) <- (x, y)
    // OUTPUTS: x0: 1 ou 0
    on_body:
        mov     x2, x27                 // x2: i
        mov     x3, #MAX_LEN            // x3: MAX_LEN

        on_body_for:
            cmp         x2, x26
            b.eq        end_on_body

            LOAD_BYTE   w4, x19, x2, x6     // x4: bx[i]
            LOAD_BYTE   w5, x20, x2, x6     // x5: by[i]

            cmp         x4, x0
            ccmp        x5, x1, #0, eq
            b.eq        end_on_body_true

            add         x2, x2, #1
            MOD         x2, x2, x3, x4      // i = (i+1)%MAX_LEN
            b           on_body_for

        end_on_body_true:
            mov         x0, 1
            ret

        end_on_body:
            LOAD_BYTE   w4, x19, x26, x6    // x4: bx[i]
            LOAD_BYTE   w5, x20, x26, x6    // x5: by[i]

            cmp         x4, x0
            ccmp        x5, x1, #0, eq
            b.eq        end_on_body_true

        mov     x0, 0
        ret

    // FONCTION `PLACE_APPLE`
    // Modification in place
    // INPUTS: aucun
    // OUTPUTS: aucun
    place_apple:
        #ifdef __FIXED_APPLE__

            mov     x4, #W
            add     x24, x24, #7
            MOD     x24, x24, x4, x5
            mov     x4, #H
            add     x25, x25, #5
            MOD     x25, x25, x4, x5

            while_place_apple:
                mov     x0, x24
                CALL    on_body
                cmp     x0, #0
                b.eq    end_place_apple

                mov     x4, #W
                add     x24, x24, #1
                MOD     x24, x24, x4, x5

                b       while_place_apple

            end_place_apple:
                ret


        #else

        mov     x0, #H
        CALL    _gfx_rand
        str     x0, [sp, #-16]!
        mov     x0, #W
        CALL    _gfx_rand
        ldr     x1, [sp], #16
        mov     x24, x0
        mov     x25, x1
        CALL    on_body
        cmp     x0, #1
        b.eq    place_apple
        ret

        #endif


    // ┌───────────────────────────┐
    // │            MAIN           │
    // └───────────────────────────┘
    main_body:
        bl      init

        mov     sp, x29
        ldp     x27, x28, [sp, #80]
        ldp     x25, x26, [sp, #64]
        ldp     x23, x24, [sp, #48]
        ldp     x21, x22, [sp, #32]
        ldp     x19, x20, [sp, #16]
        ldp     x29, x30, [sp], #96
        mov     w0, #0

        ret
