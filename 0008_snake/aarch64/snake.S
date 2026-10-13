#ifdef __APPLE__
    .macro SYSCALL nr
    mov     x16, \nr
    svc     0x80
    .endm
    .macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
    .endm
# define C(sym) _##sym
# define SYS_write 4
# define SYS_exit  1
#else
    .macro SYSCALL nr
    mov     x8, \nr
    svc     0
    .endm
    .macro ADDR reg, sym
    adrp    \reg, \sym
    add     \reg, \reg, :lo12:\sym
    .endm
# define SYS_write 64
# define SYS_exit  93
# define C(sym) sym
#endif

# define W 30
# define H 20
# define ORIGIN_Y 1
# define MAX_LEN (W*H)
# define TICK0_MS 150
# define TICK_MIN 60

.macro MODULO dividend, divisor, quotient, remainder
udiv \quotient, \dividend, \divisor
msub \remainder, \quotient, \divisor, \dividend
.endm

#ifdef __APPLE__
    .section __DATA,__data
#else
    .section .data
#endif
head: .byte 2

tail: .byte 0

dx: .byte 1

dy: .byte 0

ax: .byte 3

ay: .byte 3

tick_ms: .byte TICK0_MS

score: .byte 0

alive: .byte 1

bx_pointer:
	.quad 0, 1, 1

by_pointer:
	.quad 0, 0, 1


#ifdef __APPLE__
    .section __TEXT,__text
#else
    .section .text
#endif
    .globl C(init)
C(init):
	stp fp, lr, [sp, #-0x10]!
	mov fp, sp

	mov x0, #W
	asr x0, x0, #1 // shifts one bit to the right (/2)
	mov x1, #H
	asr x1, x1, #1
	ADDR x2, bx_pointer
	ADDR x3, by_pointer
	str x0, [x2]
	str x1, [x3]

	bl C(place_apple)
	ldp fp, lr, [sp], #0x10
	ret

C(place_apple):
	stp fp, lr, [sp, #-0x20]!
	stp x19, x20, [sp, #0x10]
	mov fp, sp
	
	#ifdef FIXED_APPLE
	ADDR x5, ax
	ldr x0, [x5]
	add x0, x0, #7
	mov x1, #W
	MODULO x0, x1, x2, x19 // x19 is (ax + 7) % W

	ADDR x5, ay
	ldr x1, [x5]
	add x1, #5
	mov x2, H
	MODULO x1, x2, x3, x20 // x20 is (ay + 5) % H

	mov x0, x19
	mov x1, x20
	bl C(on_body)
	cbz x0, End_place_apple

While_place_apple_fixed_apple:
	add x19, x19, #1
	mov x1, #W
	MODULO x19, x1, x2, x19 // x19 is (ax + 1) % W 

	mov x0, x19
	mov x1, x20
	bl C(on_body)
	cmp x0, #1
	beq While_place_apple_fixed_apple
	#else
Do_while_place_apple:
	mov x0, #W
	bl C(gfx_rand)
	mov x19, x0 // x19 = gfx_rand(W)
	mov x0, #H
	bl C(gfx_rand)
	mov x20, x0

	mov x0, x19
	mov x1, x20
	bl C(on_body)
	cmp x0, #1
	beq Do_while_place_apple
	#endif

End_place_apple:
	// store updated ax and ay in RAM
	ADDR x0, ax
	str x19, [x0]
	ADDR x1, ay
	str x20, [x1]

	// restore x19 and x20 from function stack
	ldp x19, x20, [sp, #0x10]
	ldp fp, lr, [sp], #0x20
	ret

    .globl C(on_body)
C(on_body): 
	stp fp, lr, [sp, #-0x30]!
	stp x19, x20, [sp, #0x10]
	stp x21, x22, [sp, #0x20]
	mov fp, sp

	mov x19, x0 // x19 and x20 keep the arguments (x,y) somewhere safe
	mov x20, x1

	ADDR x5, head
	ldrsb x21, [x5] // loads the byte at head into register and extends it to 64 bits.

	ADDR x5, tail
	ldrsb x22, [x5]

	ADDR x5, bx_pointer // x5 keeps the address of bx_pointer
	ADDR x6, by_pointer

	mov x2, x22

For_loop_on_body:
	ldr x0, [x5, x2, lsl #3] // loads bx_pointer[x2] into x0. 

	ldr x1, [x6, x2, lsl #3] // loadsn by_pointer[x2] into x1.

	cmp x0, x19
	ccmp x1, x20, #0, EQ // tests condB (x1 == x20) only if condA (w0 == w19) is true. Else it sets the flag to false (#0).
	bne Skip_end_on_body

	mov x0, #1
	b End_on_body 

Skip_end_on_body:
	// if x2 xas the position of the head, then the previous test xas the last one we needed to do.
	cmp x2, x21
	csel x0, xzr, x0, EQ
	beq End_on_body

	add x2, x2, #1
	mov x10, #MAX_LEN
	MODULO x2, x7, x10, x2 // x2 = x2 % MAX_LEN
	b For_loop_on_body

End_on_body:
	ldp x19, x20, [sp, #0x10]
	ldp x21, x22, [sp, #0x20]
	ldp fp, lr, [sp], #0x30
	ret

    .globl C(main)
C(main):
	stp fp, lr, [sp, #-0x10]!
	mov fp, sp

	mov x0, #0
	mov x1, #0

	bl C(on_body)
	mov x1, x0
	ADDR x0, format_str

	bl C(printf)
	mov x0, #0
	ldp fp, lr, [sp], #0x10
	ret


#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
format_str:
    .string  "hello\n"
