// int main(void): rotating donut on libgfx.
// AArch64, convention AAPCS64: x0 à x7 pour arguments, résultat dans x0.
// Registres callee-saved: x19 à x28, x29 (fp), x30 (lr).

#include "../gfx_consts.h"

#define WIDTH  80
#define HEIGHT 22
#define BUF_SIZE (WIDTH * HEIGHT)

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
// rotation angles A and B
A:          .float 0.0
B:          .float 0.0

// floating point constants used in computation
fp_zero:    .float 0.0
fp_two:     .float 2.0
fp_five:    .float 5.0
fp_eight:   .float 8.0
fp_fifteen: .float 15.0
fp_thirty:  .float 30.0
fp_center_x: .float 40.0
fp_center_y: .float 11.0
fp_two_pi:  .float 6.28
fp_step_j:  .float 0.07
fp_step_i:  .float 0.02
fp_step_A:  .float 0.04
fp_step_B:  .float 0.02

// buffers: z-buffer (float) and character buffer (char)
    .bss
    .align 4
z:          .space BUF_SIZE * 4
b:          .space BUF_SIZE

    .text
    .align 2

    .globl C(main)
C(main):
    // Local floats at sp[0:40], saved registers at sp[48:80].
    sub     sp, sp, #80
    stp     x29, x30, [sp, #48]
    stp     x19, x20, [sp, #64]
    add     x29, sp, #48

    // open graphics display: gfx_open(WIDTH, HEIGHT)
    mov     w0, #WIDTH
    mov     w1, #HEIGHT
    bl      C(gfx_open)
    cmp     w0, #0
    b.lt    fail

frame_loop:
    // clear character buffer: memset(b, ' ', BUF_SIZE)
    ADDR    x0, b
    mov     w1, #' '
    mov     x2, #BUF_SIZE
    bl      C(memset)

    // clear z-buffer: memset(z, 0, BUF_SIZE * 4)
    ADDR    x0, z
    mov     w1, #0
    mov     x2, #(BUF_SIZE * 4)
    bl      C(memset)

    // precompute trigonometric projections for current angles:
    // e = sin(A)
    ADDR    x0, A
    ldr     s0, [x0]
    bl      C(sinf)
    str     s0, [sp, #20]

    // g = cos(A)
    ADDR    x0, A
    ldr     s0, [x0]
    bl      C(cosf)
    str     s0, [sp, #24]

    // m = cos(B)
    ADDR    x0, B
    ldr     s0, [x0]
    bl      C(cosf)
    str     s0, [sp, #28]

    // n = sin(B)
    ADDR    x0, B
    ldr     s0, [x0]
    bl      C(sinf)
    str     s0, [sp, #32]

    // initialize j = 0.0f
    ADDR    x0, fp_zero
    ldr     s0, [x0]
    str     s0, [sp, #0]

loop_j:
    // check outer loop condition: j < 6.28
    ldr     s0, [sp, #0]
    ADDR    x0, fp_two_pi
    ldr     s1, [x0]
    fcmp    s0, s1
    b.ge    loop_j_end

    // compute d = cos(j)
    ldr     s0, [sp, #0]
    bl      C(cosf)
    str     s0, [sp, #8]

    // compute h = d + 2
    ADDR    x0, fp_two
    ldr     s1, [x0]
    fadd    s0, s0, s1
    str     s0, [sp, #16]

    // compute f = sin(j)
    ldr     s0, [sp, #0]
    bl      C(sinf)
    str     s0, [sp, #12]

    // initialize inner loop i = 0.0f
    ADDR    x0, fp_zero
    ldr     s0, [x0]
    str     s0, [sp, #4]

loop_i:
    // check inner loop condition: i < 6.28
    ldr     s0, [sp, #4]
    ADDR    x0, fp_two_pi
    ldr     s1, [x0]
    fcmp    s0, s1
    b.ge    loop_i_end

    // compute c = sin(i)
    ldr     s0, [sp, #4]
    bl      C(sinf)
    str     s0, [sp, #36]          // sin(i) must survive the cosf call

    // compute l = cos(i)
    ldr     s0, [sp, #4]
    bl      C(cosf)
    fmov    s17, s0
    ldr     s16, [sp, #36]          // c = sin(i)

    // load loop variables from stack frame
    ldr     s18, [sp, #8]           // d
    ldr     s19, [sp, #12]          // f
    ldr     s20, [sp, #16]          // h
    ldr     s21, [sp, #20]          // e
    ldr     s22, [sp, #24]          // g
    ldr     s23, [sp, #28]          // m
    ldr     s24, [sp, #32]          // n

    // calculate inverse depth D = 1 / (c * h * e + f * g + 5)
    fmul    s0, s16, s20
    fmul    s0, s0, s21
    fmul    s1, s19, s22
    fadd    s0, s0, s1
    ADDR    x0, fp_five
    ldr     s1, [x0]
    fadd    s0, s0, s1
    fmov    s1, #1.0
    fdiv    s25, s1, s0

    // calculate t = c * h * g - f * e
    fmul    s0, s16, s20
    fmul    s0, s0, s22
    fmul    s1, s19, s21
    fsub    s26, s0, s1

    // calculate screen coordinate x = 40 + 30 * D * (l * h * m - t * n)
    fmul    s0, s17, s20
    fmul    s0, s0, s23
    fmul    s1, s26, s24
    fsub    s0, s0, s1
    ADDR    x0, fp_thirty
    ldr     s1, [x0]
    fmul    s0, s0, s1
    fmul    s0, s0, s25
    ADDR    x0, fp_center_x
    ldr     s1, [x0]
    fadd    s0, s0, s1
    fcvtzs  w0, s0                 // truncate the complete coordinate

    // calculate screen coordinate y = 11 + 15 * D * (l * h * n + t * m)
    fmul    s1, s17, s20
    fmul    s1, s1, s24
    fmul    s2, s26, s23
    fadd    s1, s1, s2
    ADDR    x1, fp_fifteen
    ldr     s2, [x1]
    fmul    s1, s1, s2
    fmul    s1, s1, s25
    ADDR    x1, fp_center_y
    ldr     s2, [x1]
    fadd    s1, s1, s2
    fcvtzs  w1, s1

    // verify screen boundary conditions: 0 <= y < HEIGHT and 0 <= x < WIDTH
    cmp     w1, #0
    b.lt    skip_point
    cmp     w1, #HEIGHT
    b.ge    skip_point
    cmp     w0, #0
    b.lt    skip_point
    cmp     w0, #WIDTH
    b.ge    skip_point

    // compute 1D offset in buffer: o = x + WIDTH * y
    mov     w2, #WIDTH
    madd    w3, w1, w2, w0

    // test depth buffer: check if D > z[o]
    ADDR    x4, z
    ldr     s0, [x4, w3, sxtw #2]
    fcmp    s25, s0
    b.le    skip_point

    // update depth buffer: z[o] = D
    str     s25, [x4, w3, sxtw #2]

    // calculate surface luminance N = 8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n)
    fmul    s0, s19, s21
    fmul    s1, s16, s18
    fmul    s1, s1, s22
    fsub    s0, s0, s1
    fmul    s0, s0, s23

    fmul    s1, s16, s18
    fmul    s1, s1, s21
    fsub    s0, s0, s1

    fmul    s1, s19, s22
    fsub    s0, s0, s1

    fmul    s1, s17, s18
    fmul    s1, s1, s24
    fsub    s0, s0, s1

    ADDR    x5, fp_eight
    ldr     s1, [x5]
    fmul    s0, s0, s1

    // pick luminance character based on index
    ADDR    x5, luminance_chars
    ADDR    x6, fp_zero
    ldr     s1, [x6]
    fcmp    s0, s1
    b.le    lum_zero
    fcvtzs  w6, s0
    // clamp maximum index to 11
    cmp     w6, #11
    b.le    lum_store
    mov     w6, #11
    b       lum_store

lum_zero:
    mov     w6, #0

lum_store:
    ldrb    w7, [x5, w6, sxtw]
    ADDR    x8, b
    strb    w7, [x8, w3, sxtw]

skip_point:
    // advance inner step: i += 0.02
    ldr     s0, [sp, #4]
    ADDR    x0, fp_step_i
    ldr     s1, [x0]
    fadd    s0, s0, s1
    str     s0, [sp, #4]
    b       loop_i

loop_i_end:
    // advance outer step: j += 0.07
    ldr     s0, [sp, #0]
    ADDR    x0, fp_step_j
    ldr     s1, [x0]
    fadd    s0, s0, s1
    str     s0, [sp, #0]
    b       loop_j

loop_j_end:

    // clear frame display background
    mov     w0, #GFX_BLACK
    bl      C(gfx_clear)

    // initialize vertical draw coordinate: y = 0
    mov     x19, #0

draw_y_loop:
    // check if all rows are rendered
    cmp     x19, #HEIGHT
    b.ge    draw_end

    // initialize horizontal draw coordinate: x = 0
    mov     x20, #0

draw_x_loop:
    // check if current row is finished
    cmp     x20, #WIDTH
    b.ge    draw_y_next

    // read character from buffer b[y * WIDTH + x]
    mov     w0, #WIDTH
    madd    w1, w19, w0, w20
    ADDR    x2, b
    ldrsb   w3, [x2, w1, sxtw]

    // skip background spaces
    cmp     w3, #' '
    b.eq    draw_x_next

    // draw character to screen: gfx_put(x, y, ch, GFX_CYAN)
    mov     w0, w20
    mov     w1, w19
    mov     w2, w3
    mov     w3, #GFX_CYAN
    bl      C(gfx_put)

draw_x_next:
    // advance column counter
    add     x20, x20, #1
    b       draw_x_loop

draw_y_next:
    // advance row counter
    add     x19, x19, #1
    b       draw_y_loop

draw_end:
    // render instruction banner: "q: quitter"
    mov     w0, #0
    mov     w1, #0
    ADDR    x2, msg_quit
    mov     w3, #GFX_WHITE
    bl      C(gfx_text)

    // render completed frame buffer
    bl      C(gfx_present)

poll_keys:
    // drain queued keystrokes; exit if 'q' or 'Q' was pressed
    bl      C(gfx_key)
    cmp     w0, #GFX_KEY_NONE
    b.eq    no_quit
    cmp     w0, #'q'
    b.eq    quit
    cmp     w0, #'Q'
    b.eq    quit
    b       poll_keys

no_quit:

    // increment rotation angles: A += 0.04, B += 0.02
    ADDR    x0, A
    ldr     s0, [x0]
    ADDR    x1, fp_step_A
    ldr     s1, [x1]
    fadd    s0, s0, s1
    str     s0, [x0]

    ADDR    x0, B
    ldr     s0, [x0]
    ADDR    x1, fp_step_B
    ldr     s1, [x1]
    fadd    s0, s0, s1
    str     s0, [x0]

    // delay 30ms before next frame
    mov     w0, #30
    bl      C(gfx_sleep)
    b       frame_loop

quit:
    // restore terminal state and return 0
    bl      C(gfx_close)
    mov     w0, #0
    b       ret

fail:
    // return 1 on initialization error
    mov     w0, #1

ret:
    ldp     x19, x20, [sp, #64]
    ldp     x29, x30, [sp, #48]
    add     sp, sp, #80
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
luminance_chars:
    .asciz ".,-~:;=!*#$@"
msg_quit:
    .asciz "press q to quit"
