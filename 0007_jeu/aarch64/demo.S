// Même programme que demo.c, en assembleur AArch64.
// Convention AAPCS64: arguments dans x0 à x7, résultat dans x0; x19 à x28
// sauvés par l'appelé. La position (x, y) est gardée dans w19 et w20.

#include "../gfx_consts.h"

#ifdef __APPLE__
# define C(sym) _##sym
    .macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
    .endm
#else
# define C(sym) sym
    .macro ADDR reg, sym
    adrp    \reg, \sym
    add     \reg, \reg, :lo12:\sym
    .endm
#endif

    .text
    .globl C(main)
C(main):
    stp     x29, x30, [sp, #-32]!   // fp, lr
    stp     x19, x20, [sp, #16]     // x, y
    mov     x29, sp
    mov     w19, #30                // x
    mov     w20, #10                // y

    mov     w0, #60
    mov     w1, #20
    bl      C(gfx_open)
    cbnz    w0, .Lfail

.Lloop:
    mov     w0, #GFX_BLACK
    bl      C(gfx_clear)

    mov     w0, w19                 // gfx_rect(x, y, 2, 1, '#', GFX_GREEN)
    mov     w1, w20
    mov     w2, #2
    mov     w3, #1
    mov     w4, #'#'
    mov     w5, #GFX_GREEN
    bl      C(gfx_rect)

    mov     w0, #0                  // gfx_text(0, 0, aide, GFX_WHITE)
    mov     w1, #0
    ADDR    x2, aide
    mov     w3, #GFX_WHITE
    bl      C(gfx_text)

    bl      C(gfx_present)

    bl      C(gfx_key)              // k dans w0
    cmp     w0, #'q'
    b.eq    .Lquit
    cmp     w0, #GFX_KEY_LEFT
    b.ne    1f
    cmp     w19, #0
    b.eq    1f
    sub     w19, w19, #1
1:  cmp     w0, #GFX_KEY_RIGHT
    b.ne    2f
    cmp     w19, #58
    b.ge    2f
    add     w19, w19, #1
2:  cmp     w0, #GFX_KEY_UP
    b.ne    3f
    cmp     w20, #1
    b.le    3f
    sub     w20, w20, #1
3:  cmp     w0, #GFX_KEY_DOWN
    b.ne    4f
    cmp     w20, #19
    b.ge    4f
    add     w20, w20, #1
4:  mov     w0, #30
    bl      C(gfx_sleep)
    b       .Lloop

.Lquit:
    bl      C(gfx_close)
    mov     w0, #0
    b       .Lret
.Lfail:
    mov     w0, #1
.Lret:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
aide:
    .asciz  "fleches: deplacer, q: quitter"
