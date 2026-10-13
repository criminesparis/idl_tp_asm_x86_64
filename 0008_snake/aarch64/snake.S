// Snake in AArch64, using the same libgfx calls as demo.S.
// Arguments: x0-x7; result: x0. Save x19-x28 when using them.

#include "../gfx_consts.h"

#define W        30
#define H        20
#define ORIGIN_Y 1
#define MAX_LEN  (W * H)
#define TICK0_MS 150
#define TICK_MIN 60

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

    .data
    .align 4
bx:         .space MAX_LEN * 4
by:         .space MAX_LEN * 4
head:       .word 0
tail:       .word 0
len:        .word 1
dx:         .word 1
dy:         .word 0
ax:         .word 3
ay:         .word 3
score:      .word 0
tick_ms:    .word TICK0_MS
alive:      .word 1

    .align 3
script:     .quad 0

body_sprite:
    .byte 2, 1, '[', GFX_GREEN, ']', GFX_GREEN
head_sprite:
    .byte 2, 1, '(', GFX_GREEN, ')', GFX_GREEN
apple_sprite:
    .byte 2, 1, '@', GFX_RED, ' ', GFX_BLACK

    .text
    .align 2

// Check exactly len cells, starting at the tail.
    .globl C(on_body)
C(on_body):
    ADDR    x2, tail
    ldr     w3, [x2]                // i = tail
    ADDR    x2, len
    ldr     w4, [x2]                // cells left to check
    ADDR    x5, bx
    ADDR    x6, by

.L_onbody_loop:
    cbz     w4, .L_onbody_notfound
    ldr     w7, [x5, w3, uxtw #2]
    cmp     w7, w0
    b.ne    .L_onbody_next
    ldr     w7, [x6, w3, uxtw #2]
    cmp     w7, w1
    b.eq    .L_onbody_found

.L_onbody_next:
    add     w3, w3, #1
    cmp     w3, #MAX_LEN
    b.lt    1f
    mov     w3, #0
1:  sub     w4, w4, #1
    b       .L_onbody_loop

.L_onbody_found:
    mov     w0, #1
    ret
.L_onbody_notfound:
    mov     w0, #0
    ret

// Pick an apple outside the snake.
    .globl C(place_apple)
C(place_apple):
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

.L_place_apple_retry:
    mov     w0, #W
    bl      C(gfx_rand)
    ADDR    x1, ax
    str     w0, [x1]

    mov     w0, #H
    bl      C(gfx_rand)
    ADDR    x2, ay
    str     w0, [x2]

    ADDR    x1, ax
    ldr     w0, [x1]
    ADDR    x2, ay
    ldr     w1, [x2]
    bl      C(on_body)
    cbnz    w0, .L_place_apple_retry

    ldp     x29, x30, [sp], #16
    ret

// Reset the snake to one cell in the middle of the board.
    .globl C(init)
C(init):
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    ADDR    x0, head
    str     wzr, [x0]
    ADDR    x0, tail
    str     wzr, [x0]
    ADDR    x0, len
    mov     w1, #1
    str     w1, [x0]

    ADDR    x0, bx
    mov     w1, #(W / 2)
    str     w1, [x0]
    ADDR    x0, by
    mov     w1, #(H / 2)
    str     w1, [x0]

    ADDR    x0, dx
    mov     w1, #1
    str     w1, [x0]
    ADDR    x0, dy
    str     wzr, [x0]

    ADDR    x0, ax
    mov     w1, #3
    str     w1, [x0]
    ADDR    x0, ay
    mov     w1, #3
    str     w1, [x0]

    bl      C(place_apple)

    ADDR    x0, score
    str     wzr, [x0]
    ADDR    x0, tick_ms
    mov     w1, #TICK0_MS
    str     w1, [x0]
    ADDR    x0, alive
    mov     w1, #1
    str     w1, [x0]

    ldp     x29, x30, [sp], #16
    ret

// Reject a reverse turn when the snake has more than one cell.
    .globl C(turn)
C(turn):
    ADDR    x2, len
    ldr     w3, [x2]
    cmp     w3, #1
    b.le    .L_turn_apply

    ADDR    x4, dx
    ldr     w5, [x4]
    ADDR    x6, dy
    ldr     w7, [x6]

    neg     w8, w5
    cmp     w0, w8
    b.ne    .L_turn_apply
    neg     w9, w7
    cmp     w1, w9
    b.eq    .L_turn_ret

.L_turn_apply:
    ADDR    x4, dx
    str     w0, [x4]
    ADDR    x6, dy
    str     w1, [x6]

.L_turn_ret:
    ret

// Move one cell, then grow if we ate the apple.
    .globl C(step)
C(step):
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]     // nx, ny
    stp     x21, x22, [sp, #32]     // eat, old tail

    ADDR    x0, head
    ldr     w1, [x0]
    ADDR    x2, bx
    ldr     w3, [x2, w1, sxtw #2]
    ADDR    x4, dx
    ldr     w5, [x4]
    add     w19, w3, w5

    ADDR    x2, by
    ldr     w3, [x2, w1, sxtw #2]
    ADDR    x4, dy
    ldr     w5, [x4]
    add     w20, w3, w5

    cmp     w19, #0
    b.lt    .L_step_die
    cmp     w19, #W
    b.ge    .L_step_die
    cmp     w20, #0
    b.lt    .L_step_die
    cmp     w20, #H
    b.ge    .L_step_die

    ADDR    x0, ax
    ldr     w1, [x0]
    ADDR    x2, ay
    ldr     w3, [x2]
    cmp     w19, w1
    b.ne    1f
    cmp     w20, w3
    b.ne    1f
    mov     w21, #1
    b       2f
1:
    mov     w21, #0
2:
    // Remove the tail before checking collisions; length 1 becomes empty.
    ADDR    x0, tail
    ldr     w22, [x0]
    cbnz    w21, .L_step_check_body
    add     w1, w22, #1
    cmp     w1, #MAX_LEN
    b.lt    4f
    mov     w1, #0
4:  str     w1, [x0]
    ADDR    x0, len
    ldr     w1, [x0]
    sub     w1, w1, #1
    str     w1, [x0]

.L_step_check_body:
    mov     w0, w19
    mov     w1, w20
    bl      C(on_body)
    cbnz    w0, .L_step_collision

    ADDR    x0, head
    ldr     w1, [x0]
    add     w1, w1, #1
    cmp     w1, #MAX_LEN
    b.lt    6f
    mov     w1, #0
6:
    str     w1, [x0]

    ADDR    x2, bx
    str     w19, [x2, w1, sxtw #2]
    ADDR    x3, by
    str     w20, [x3, w1, sxtw #2]

    // Add the new head: restore length, or grow by one if eating.
    ADDR    x0, len
    ldr     w1, [x0]
    add     w1, w1, #1
    str     w1, [x0]

    cbz     w21, .L_step_done
    ADDR    x0, score
    ldr     w1, [x0]
    add     w1, w1, #10
    str     w1, [x0]

    ADDR    x2, tick_ms
    ldr     w3, [x2]
    cmp     w3, #TICK_MIN
    b.le    7f
    sub     w3, w3, #5
    str     w3, [x2]
7:
    // A full board is a win: there is no space for another apple.
    ADDR    x0, len
    ldr     w1, [x0]
    cmp     w1, #MAX_LEN
    b.eq    .L_step_die
    bl      C(place_apple)
    b       .L_step_done

.L_step_collision:
    // Keep the last valid body visible after a collision.
    cbnz    w21, .L_step_die
    ADDR    x0, tail
    str     w22, [x0]
    ADDR    x0, len
    ldr     w1, [x0]
    add     w1, w1, #1
    str     w1, [x0]

.L_step_die:
    ADDR    x0, alive
    str     wzr, [x0]

.L_step_done:
    ldp     x21, x22, [sp, #32]
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

// Draw the board, sprites and score.
    .globl C(draw)
C(draw):
    sub     sp, sp, #144
    stp     x29, x30, [sp, #16]
    add     x29, sp, #16
    stp     x19, x20, [sp, #32]     // message, loop index
    stp     x21, x22, [sp, #48]     // head, unused

    mov     x19, x0                 // message

    mov     w0, #GFX_BLACK
    bl      C(gfx_clear)

    mov     w0, #0
    mov     w1, #ORIGIN_Y
    mov     w2, #(2 * W)
    mov     w3, #H
    mov     w4, #'.'
    mov     w5, #GFX_BLUE
    bl      C(gfx_rect)

    ADDR    x0, tail
    ldr     w20, [x0]               // i = tail
    ADDR    x1, head
    ldr     w21, [x1]               // head

.L_draw_body_loop:
    cmp     w20, w21
    b.eq    .L_draw_body_end

    ADDR    x2, bx
    ldr     w0, [x2, w20, sxtw #2]
    lsl     w0, w0, #1
    ADDR    x3, by
    ldr     w1, [x3, w20, sxtw #2]
    add     w1, w1, #ORIGIN_Y
    ADDR    x2, body_sprite
    bl      C(gfx_blit)

    add     w20, w20, #1
    cmp     w20, #MAX_LEN
    b.lt    1f
    mov     w20, #0
1:
    b       .L_draw_body_loop

.L_draw_body_end:
    ADDR    x2, bx
    ldr     w0, [x2, w21, sxtw #2]
    lsl     w0, w0, #1
    ADDR    x3, by
    ldr     w1, [x3, w21, sxtw #2]
    add     w1, w1, #ORIGIN_Y
    ADDR    x2, head_sprite
    bl      C(gfx_blit)

    ADDR    x0, len
    ldr     w0, [x0]
    cmp     w0, #MAX_LEN
    b.eq    .L_draw_hud
    ADDR    x0, ax
    ldr     w0, [x0]
    lsl     w0, w0, #1
    ADDR    x1, ay
    ldr     w1, [x1]
    add     w1, w1, #ORIGIN_Y
    ADDR    x2, apple_sprite
    bl      C(gfx_blit)

.L_draw_hud:
    // Messages can go directly to gfx_text; only the score needs formatting.
    cbnz    x19, .L_draw_message
    ADDR    x0, score
    ldr     w3, [x0]
    ADDR    x0, len
    ldr     w4, [x0]
#ifdef __APPLE__
    stp     x3, x4, [sp]            // macOS variadic arguments
#endif
    add     x0, sp, #64             // hud[80], after the saved registers
    mov     w1, #80
    ADDR    x2, fmt_score
    bl      C(snprintf)
    add     x2, sp, #64
    b       .L_draw_text

.L_draw_message:
    mov     x2, x19
.L_draw_text:
    mov     w0, #0
    mov     w1, #0
    mov     w3, #GFX_WHITE
    bl      C(gfx_text)

    bl      C(gfx_present)

    ldp     x21, x22, [sp, #48]
    ldp     x19, x20, [sp, #32]
    ldp     x29, x30, [sp, #16]
    add     sp, sp, #144
    ret

// Read one scripted key, or the latest keyboard input.
    .globl C(last_key)
C(last_key):
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    ADDR    x0, script
    ldr     x19, [x0]
    cbz     x19, .L_key_interactive

    ldrb    w1, [x19]
    cbnz    w1, 1f
    mov     w0, #GFX_KEY_NONE
    b       .L_key_ret
1:
    add     x2, x19, #1
    str     x2, [x0]

    cmp     w1, #'L'
    b.ne    2f
    mov     w0, #GFX_KEY_LEFT
    b       .L_key_ret
2:  cmp     w1, #'R'
    b.ne    3f
    mov     w0, #GFX_KEY_RIGHT
    b       .L_key_ret
3:  cmp     w1, #'U'
    b.ne    4f
    mov     w0, #GFX_KEY_UP
    b       .L_key_ret
4:  cmp     w1, #'D'
    b.ne    5f
    mov     w0, #GFX_KEY_DOWN
    b       .L_key_ret
5:  mov     w0, w1
    b       .L_key_ret

.L_key_interactive:
    mov     w19, #GFX_KEY_NONE
.L_key_loop:
    bl      C(gfx_key)
    cmp     w0, #GFX_KEY_NONE
    b.eq    .L_key_interactive_done
    mov     w19, w0
    b       .L_key_loop

.L_key_interactive_done:
    mov     w0, w19

.L_key_ret:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret

// Open libgfx and run one movement per tick.
    .globl C(main)
C(main):
    sub     sp, sp, #48
    stp     x29, x30, [sp, #16]     // leave sp[0:16] for printf arguments
    add     x29, sp, #16
    stp     x19, x20, [sp, #32]     // next, wait

    cmp     w0, #1
    b.le    1f
    ldr     x2, [x1, #8]
    ADDR    x3, script
    str     x2, [x3]
1:
    mov     w0, #(2 * W)
    mov     w1, #(H + ORIGIN_Y)
    bl      C(gfx_open)
    cmp     w0, #0
    b.lt    .L_main_fail

    bl      C(init)

    bl      C(gfx_ticks)
    mov     x19, x0

.L_main_loop:
    bl      C(last_key)
    cmp     w0, #'q'
    b.eq    .L_main_break

    cmp     w0, #GFX_KEY_LEFT
    b.ne    2f
    mov     w0, #-1
    mov     w1, #0
    bl      C(turn)
    b       6f
2:  cmp     w0, #GFX_KEY_RIGHT
    b.ne    3f
    mov     w0, #1
    mov     w1, #0
    bl      C(turn)
    b       6f
3:  cmp     w0, #GFX_KEY_UP
    b.ne    4f
    mov     w0, #0
    mov     w1, #-1
    bl      C(turn)
    b       6f
4:  cmp     w0, #GFX_KEY_DOWN
    b.ne    6f
    mov     w0, #0
    mov     w1, #1
    bl      C(turn)
6:
    ADDR    x0, alive
    ldr     w0, [x0]
    cbz     w0, 7f
    bl      C(step)
7:
    ADDR    x0, alive
    ldr     w0, [x0]
    cbnz    w0, 8f
    ADDR    x0, len
    ldr     w0, [x0]
    cmp     w0, #MAX_LEN
    b.eq    .L_main_won
    ADDR    x0, msg_lost
    b       9f
.L_main_won:
    ADDR    x0, msg_won
    b       9f
8:
    mov     x0, #0
9:
    bl      C(draw)

    ADDR    x0, alive
    ldr     w0, [x0]
    cbnz    w0, .L_check_script

.L_wait_dead:
    bl      C(last_key)
    cmp     w0, #'q'
    b.eq    .L_main_break
    ADDR    x1, script
    ldr     x1, [x1]
    cbz     x1, 10f
    ldrb    w2, [x1]
    cbz     w2, .L_main_break
10:
    mov     w0, #50
    bl      C(gfx_sleep)
    b       .L_wait_dead

.L_check_script:
    ADDR    x0, script
    ldr     x0, [x0]
    cbz     x0, .L_time_wait
    ldrb    w1, [x0]
    cbnz    w1, .L_time_wait
    mov     w0, #300
    bl      C(gfx_sleep)
    b       .L_main_break

.L_time_wait:
    ADDR    x0, tick_ms
    ldr     w0, [x0]
    sxtw    x0, w0
    add     x19, x19, x0
    bl      C(gfx_ticks)
    sub     x20, x19, x0
    cmp     x20, #0
    b.le    .L_main_loop
    mov     w0, w20
    bl      C(gfx_sleep)
    b       .L_main_loop

.L_main_break:
    bl      C(gfx_close)

#ifdef __APPLE__
    ADDR    x1, score
    ldr     w1, [x1]
    ADDR    x2, len
    ldr     w2, [x2]
    stp     x1, x2, [sp]
    ADDR    x0, fmt_final
    bl      C(printf)
#else
    ADDR    x0, fmt_final
    ADDR    x1, score
    ldr     w1, [x1]
    ADDR    x2, len
    ldr     w2, [x2]
    bl      C(printf)
#endif

    mov     w0, #0
    b       .L_main_ret

.L_main_fail:
    mov     w0, #1

.L_main_ret:
    ldp     x19, x20, [sp, #32]
    ldp     x29, x30, [sp, #16]
    add     sp, sp, #48
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
fmt_score:
    .asciz  "Score %d  Longueur %d   fleches, q: quitter"
fmt_final:
    .asciz  "Score final: %d, longueur %d\n"
msg_lost:
    .asciz  "Perdu. q pour quitter"
msg_won:
    .asciz  "Gagne ! q pour quitter"
