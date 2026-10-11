#define W        30
#define TWO_W    (2 * W)
#define H        20
#define W_INIT   W / 2
#define H_INIT   H / 2
#define ORIGIN_Y 1
#define MAX_LEN  (W * H)
#define TICK0_MS 150
#define TICK_MIN 60

#define __FIXED_APPLE__

#include "gfx_consts.h"

.macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
.endm

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
        mov     x0, #TICK0_MS
        stp     xzr, x0, [sp, #-16]!    // [fp-8]: tick_ms, [fp-16]: score
        // J'ai fais le choix d'un array de byte au lien d'un array de int (8 bytes)
        // Première raison: un int est très gros par rapport à des coordonnées sur un écran
        // Seconde raison: sub ne prend que des imm < 4096 (immediate values de 12bits seulement)
        // Mais ça peut coincer lorsque H*W > 4095 ou que H > 255 ou que W > 255.
        sub     sp, sp, #MAX_LEN
        mov     x19, sp                 // x19: pointeur vers bx
        sub     sp, sp, #MAX_LEN
        mov     x20, sp                 // x20: pointeur vers by
        mov     x21, #1                 // x21: dx
        mov     x22, #0                 // x22: dy
        mov     x23, #1                 // x23: len
        mov     x24, #3                 // x24: ax
        mov     x25, #3                 // x25: ay
        mov     x26, #0                 // x26: head
        mov     x27, #0                 // x27: tail
        mov     x28, #1                 // x28: alive
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

            LOAD_BYTE   w4, x19, x2, x6     // w4: bx[i]
            LOAD_BYTE   w5, x20, x2, x6     // w5: by[i]

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
            LOAD_BYTE   w4, x19, x26, x6    // w4: bx[head]
            LOAD_BYTE   w5, x20, x26, x6    // w5: by[head]

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
                mov     x1, x25
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

    // FONCTION `STEP`
    // INPUTS: aucun
    // OUTPUTS: aucun
    step:
        LOAD_BYTE   w2, x19, x26, x4     // w2: bx[head]
        LOAD_BYTE   w3, x20, x26, x4     // w3: by[head]
        add         x0, x2, x21          // x0: nx
        add         x1, x3, x22          // x1: ny

        // Vérifier contact avec bordures
        mov         x6, #1
        cmp         x0, #0
        csel        x2, x6, xzr, lt
        cmp         x0, #W
        csel        x3, x6, xzr, ge
        cmp         x1, #0
        csel        x4, x6, xzr, lt
        cmp         x1, #H
        csel        x5, x6, xzr, ge
        orr         x2, x2, x3
        orr         x2, x2, x4
        orr         x2, x2, x5
        cmp         x2, #1
        b.eq        step_die

        // int eat = (nx == ax && ny == ay);
        cmp         x0, x24
        ccmp        x1, x25, #0, eq
        csel        x2, x6, xzr, eq   // x2: eat

        // if (!eat) tail = (tail + 1) % MAX_LEN;
        cmp         x2, #1
        b.eq        step_else
        add         x27, x27, #1
        mov         x3, #MAX_LEN
        MOD         x27, x27, x3, x4
        b           step_suite

        step_else:
        add         x23, x23, #1

        step_suite:
        // if (on_body(nx, ny)) { alive = 0; return; }
        mov         x7, x0          // x7 n'est pas changé par on_body
        CALL        on_body
        cmp         x0, #1
        b.eq        step_die
        mov         x0, x7

        // head = (head + 1) % MAX_LEN;
        mov         x3, #MAX_LEN
        add         x26, x26, #1
        MOD         x26, x26, x3, x4

        // bx[head] = nx; by[head] = ny;
        add         x3, x19, x26
        strb        w0, [x3]
        add         x3, x20, x26
        strb        w1, [x3]

        cmp         x2, #1
        b.ne        step_ret

        // score += 10;
        sub         x4, x29, #16
        ldr         x3, [x4]
        add         x3, x3, #10
        str         x3, [x4]

        // if (tick_ms > TICK_MIN) tick_ms -= 5;
        sub         x4, x29, #8
        ldr         x3, [x4]
        cmp         x3, #TICK_MIN
        b.le        step_suite_2
        sub         x3, x3, #5
        str         x3, [x4]

        step_suite_2:
            CALL    place_apple

        step_ret:
            ret

        step_die:
            mov         x28, #0
            ret

    // FONCTION `TURN`
    // INPUTS: (x0, x1) <- (ndx, ndy)
    // OUTPUTS: aucun
    turn:
        neg     x2, x21
        neg     x3, x22
        cmp     x0, x2
        ccmp    x1, x3, #0, eq
        ccmp    x23, #1, #0, eq
        b.gt    turn_end

        mov     x21, x0
        mov     x22, x1

        turn_end:
            ret

    // FONCTION `DRAW`
    // INPUTS: (x0) <- (*message)
    // OUTPUTS: aucun
    draw:
        // store pointeur message
        str     x0, [sp, #-16]!

        // char hud[80];
        sub     sp, sp, #80

        // gfx_clear(GFX_BLACK);
        mov     x0, #GFX_BLACK
        CALL    _gfx_clear

        // gfx_rect(0, ORIGIN_Y, 2 * W, H, '.', GFX_BLUE);
        mov     x0, #0
        mov     x1, #ORIGIN_Y
        mov     x2, #TWO_W
        mov     x3, #H
        mov     x4, #46     // '.' = 46
        mov     x5, #GFX_BLUE
        CALL    _gfx_rect

        // for (int i = tail; i != head; i = (i + 1) % MAX_LEN)
        sub     sp, sp, #16
        str     x27, [sp]               // draw-loop i
        draw_body_loop:
            ldr     x9, [sp]
            cmp     x9, x26
            b.eq    draw_suite

            // gfx_blit(2 * bx[i], ORIGIN_Y + by[i], body_sprite)
            add     x10, x19, x9
            ldrb    w0, [x10]
            lsl     x0, x0, #1
            add     x10, x20, x9
            ldrb    w1, [x10]
            add     x1, x1, #ORIGIN_Y
            ADDR    x2, body_sprite
            CALL    _gfx_blit

            ldr     x9, [sp]
            add     x9, x9, #1
            cmp     x9, #MAX_LEN
            csel    x9, xzr, x9, eq
            str     x9, [sp]
            b       draw_body_loop

        draw_suite:
            add     sp, sp, #16
            // gfx_blit(2 * bx[head], ORIGIN_Y + by[head], head_sprite)
            add     x10, x19, x26
            ldrb    w0, [x10]
            lsl     x0, x0, #1
            add     x10, x20, x26
            ldrb    w1, [x10]
            add     x1, x1, #ORIGIN_Y
            ADDR    x2, head_sprite
            CALL    _gfx_blit

            // gfx_blit(2 * ax, ORIGIN_Y + ay, apple_sprite)
            lsl     x0, x24, #1
            add     x1, x25, #ORIGIN_Y
            ADDR    x2, apple_sprite
            CALL    _gfx_blit

        // if (message) snprintf(hud, sizeof hud, "%s", message);
        mov     x0, sp
        mov     x1, #80
        ldr     x3, [sp, #80]
        cmp     x3, xzr
        b.eq    draw_else
        ADDR    x2, custom_msg
        CALL    _snprintf
        b       draw_suite_2

        draw_else:
        ADDR    x2, default_msg
        sub     x4, x29, #16
        ldr     x3, [x4]
        mov     x4, x23
        CALL    _snprintf

        draw_suite_2:
        mov     x0, xzr
        mov     x1, xzr
        mov     x2, sp
        mov     x3, #GFX_WHITE
        CALL    _gfx_text

        CALL    _gfx_present

        add     sp, sp, #96 // pop hud et msg
        ret

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

    .section __TEXT,__const
body_sprite:
    .byte 2, 1, '[', GFX_GREEN, ']', GFX_GREEN
head_sprite:
    .byte 2, 1, '(', GFX_GREEN, ')', GFX_GREEN
apple_sprite:
    .byte 2, 1, '@', GFX_RED, ' ', GFX_BLACK
    .section __TEXT,__cstring
custom_msg:
    .asciz  "%s"
default_msg:
    .asciz  "Score %d  Longueur %d   fleches, q: quitter"
