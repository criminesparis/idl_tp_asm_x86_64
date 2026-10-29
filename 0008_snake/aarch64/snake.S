#include "../gfx_consts.h"

#define C(sym) _##sym

    .macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
    .endm


W              = 30
H              = 20
MAX_LEN        = W * H     
MAX_LEN_BYTES  = MAX_LEN * 4  
ORIGIN_Y       = 1
TICK0_MS       = 150
TICK_MIN       = 60

    .section __TEXT,__const
    .p2align 2

    .globl  _W
_W:         .word   W

    .globl  _H
_H:         .word   H

    .globl  _MAX_LEN
_MAX_LEN:   .word   MAX_LEN

    .globl  _ORIGIN_Y
_ORIGIN_Y:  .word   ORIGIN_Y

    .globl  _TICK0_MS
_TICK0_MS:  .word   TICK0_MS

    .globl  _TICK_MIN
_TICK_MIN:  .word   TICK_MIN


    .data
    .p2align 2

    .globl  _head
_head:      .word   0

    .globl  _tail
_tail:      .word   0

    .globl  _ax
_ax:        .word   3

    .globl  _ay
_ay:        .word   3

    .globl  _len
_len:       .word   1

    .globl  _dx
_dx:        .word   1

    .globl  _dy
_dy:        .word   0

    .globl  _score
_score:     .word   0

    .globl  _tick_ms
_tick_ms:   .word   TICK0_MS

    .globl  _alive
_alive:     .word   1

    .globl  _bx
_bx:        .zero   MAX_LEN_BYTES

    .globl  _by
_by:        .zero   MAX_LEN_BYTES


.text
    .globl  C(on_body)
    .p2align 2


C(on_body):
    ADDR    x9, _tail
    ldr     w2, [x9]

    ADDR    x9, _head
    ldr     w3, [x9]

    ADDR    x9, _MAX_LEN
    ldr     w4, [x9]

    ADDR    x5, _bx
    ADDR    x6, _by

L_loop_check:
    cmp     w2, w3
    b.eq    L_check_head

    ldr     w7, [x5, w2, uxtw #2] // because we chose to use word and not quad
    cmp     w7, w0
    b.ne    L_loop_next

    ldr     w8, [x6, w2, uxtw #2]
    cmp     w8, w1
    b.ne    L_loop_next

    mov     w0, #1
    ret

L_loop_next:
    add     w2, w2, #1
    cmp     w2, w4
    b.lt    L_loop_check
    mov     w2, #0
    b       L_loop_check

L_check_head:
    ldr     w7, [x5, w3, uxtw #2]
    cmp     w7, w0
    b.ne    L_return_false

    ldr     w8, [x6, w3, uxtw #2]
    cmp     w8, w1
    b.ne    L_return_false

    mov     w0, #1
    ret

L_return_false:
    mov     w0, #0
    ret

    .globl  C(place_apple)
    .p2align 2

C(place_apple):
    stp     x29, x30, [sp, #-48]! // because non leaf function
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    ADDR    x19, _ax
    ADDR    x20, _ay
    ADDR    x21, _W
    ADDR    x22, _H

L_place_apple:
    ldr     w0, [x21]
    bl      C(gfx_rand)
    str     w0, [x19]

    ldr     w0, [x22]
    bl      C(gfx_rand)
    str     w0, [x20]

    ldr     w0, [x19]
    ldr     w1, [x20]
    bl      C(on_body)
    cbnz    w0, L_place_apple

    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

    .globl  C(init)
    .p2align 2

C(init):
    stp     x29, x30, [sp, #-16]! // non-leaf function but we do not need to save more (like we did in place apple) because here the values that we'll modify does not need to be retrieved after a bl call 
    mov     x29, sp

    ADDR    x8, _head
    ADDR    x9, _tail
    ADDR    x10, _len

    mov     w0, #0
    str     w0, [x8]
    str     w0, [x9]

    mov     w0, #1
    str     w0, [x10]

    ADDR    x8, _bx
    ADDR    x9, _by
    mov     w0, #(W / 2)
    str     w0, [x8]
    mov     w0, #(H / 2)
    str     w0, [x9]

    ADDR    x8, _dx
    mov     w0, #1
    str     w0, [x8]

    ADDR    x8, _dy
    mov     w0, #0
    str     w0, [x8]

    ADDR    x8, _ax
    mov     w0, #3
    str     w0, [x8]

    ADDR    x8, _ay
    mov     w0, #3
    str     w0, [x8]

    bl      C(place_apple)

    ADDR    x8, _score
    mov     w0, #0
    str     w0, [x8]

    ADDR    x8, _tick_ms
    mov     w0, #TICK0_MS
    str     w0, [x8]

    ADDR    x8, _alive
    mov     w0, #1
    str     w0, [x8]

    ldp     x29, x30, [sp], #16
    ret

    .globl  C(step)
    .p2align 2

C(step):
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp

    ADDR    x8, _head
    ldr     w9, [x8]
    ADDR    x10, _bx
    ldr     w11, [x10, w9, uxtw #2]
    ADDR    x10, _dx
    ldr     w12, [x10]
    add     w11, w11, w12
    str     w11, [sp, #16]  // we calcuted nx 

    ADDR    x10, _by
    ldr     w13, [x10, w9, uxtw #2]
    ADDR    x10, _dy
    ldr     w12, [x10]
    add     w13, w13, w12
    str     w13, [sp, #20]  // we calculated ny

    cmp     w11, #0
    b.lt    L_step_dead
    cmp     w11, #W
    b.ge    L_step_dead
    cmp     w13, #0
    b.lt    L_step_dead
    cmp     w13, #H
    b.ge    L_step_dead  // we made the first if 

    ADDR    x10, _ax
    ldr     w12, [x10]
    cmp     w11, w12
    b.ne    L_step_not_eat
    ADDR    x10, _ay
    ldr     w12, [x10]
    cmp     w13, w12
    b.ne    L_step_not_eat

    mov     w12, #1
    str     w12, [sp, #24]             // eat = 1
    b       L_step_update_length

L_step_not_eat:
    str     wzr, [sp, #24]             // eat = 0
    ADDR    x10, _tail
    ldr     w12, [x10]
    add     w12, w12, #1
    cmp     w12, #MAX_LEN
    b.lt    L_step_store_tail
    mov     w12, #0

L_step_store_tail:
    str     w12, [x10]
    b       L_step_check_body

L_step_update_length:
    ADDR    x10, _len
    ldr     w12, [x10]
    add     w12, w12, #1
    str     w12, [x10]

L_step_check_body:
    ldr     w0, [sp, #16]
    ldr     w1, [sp, #20]
    bl      C(on_body)
    cbnz    w0, L_step_dead

    ADDR    x10, _head
    ldr     w9, [x10]
    add     w9, w9, #1
    cmp     w9, #MAX_LEN
    b.lt    L_step_store_head
    mov     w9, #0

L_step_store_head:
    str     w9, [x10]
    ADDR    x10, _bx
    ldr     w11, [sp, #16]
    str     w11, [x10, w9, uxtw #2]
    ADDR    x10, _by
    ldr     w11, [sp, #20]
    str     w11, [x10, w9, uxtw #2]

    ldr     w12, [sp, #24]
    cbz     w12, L_step_return

    ADDR    x10, _score
    ldr     w11, [x10]
    add     w11, w11, #10
    str     w11, [x10]

    ADDR    x10, _tick_ms
    ldr     w11, [x10]
    cmp     w11, #TICK_MIN
    b.le    L_step_place_apple
    sub     w11, w11, #5
    str     w11, [x10]

L_step_place_apple:
    bl      C(place_apple)

L_step_return:
    ldp     x29, x30, [sp], #32
    ret

L_step_dead:
    ADDR    x8, _alive
    str     wzr, [x8]
    b       L_step_return

    .globl  C(turn)
    .p2align 2

C(turn):
    ADDR    x8, _dx
    ldr     w2, [x8]
    neg     w2, w2
    cmp     w0, w2
    b.ne    L_turn_store

    ADDR    x8, _dy
    ldr     w2, [x8]
    neg     w2, w2
    cmp     w1, w2
    b.ne    L_turn_store

    ADDR    x8, _len
    ldr     w2, [x8]
    cmp     w2, #1
    b.gt    L_turn_return

L_turn_store:
    ADDR    x8, _dx
    str     w0, [x8]
    ADDR    x8, _dy
    str     w1, [x8]

L_turn_return:
    ret