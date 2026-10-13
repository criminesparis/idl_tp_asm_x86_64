// int64_t fibrec(int64_t x)
// int64_t fibiter(int64_t x)
// AArch64, convention AAPCS64: x -> x0, résultat dans x0.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fibrec)
C(fibrec):
	stp fp, lr, [sp, #-0x20]!
	stp w19, w20, [sp, #0x10]
	mov fp, sp

	cmp w0, #2
	blt end_fibrec // jump to end (as in that case we want to return n (=w0) )
	
	sub w0, w0, #1 // n <- n - 1
	mov w19, w0 // keep a copy of n - 1 before calling recursively fibrec
	bl C(fibrec) // calling fibrec recursively
	mov w20, w0 // keep the result of fibrec (n-1) in w20

	sub w0, w19, #1 // n <- n - 1 
	bl C(fibrec) // calling fibrec (n-2)
	add w0, w0, w20 // result = fibrec(n-1) (in w20) + fibrec(n-2) (in w0) -> result in w0

	end_fibrec:
	ldp w19, w20, [sp, #0x10]
	ldp fp, lr, [sp], #0x20
	ret

	.globl C(fibiter)
C(fibiter):
	mov w3, w0 // instantiate loop tracker
	mov w0, #0
	mov w1, #1
	cmp w3, #0
	beq end_fibiter

	loop_fibiter:
	mov w4, w0 // keep w0 initial value
	mov w0, w1 // a <- b
	add w1, w4, w1 // b <- a + b (with previous value of a)
	
	subs w3, w3, #1
	bne loop_fibiter

	end_fibiter:
	ret

	.globl C(fibinet)
C(fibinet):
	fmov d0, 5.0
	fsqrt d0, d0 // d0 <- sqrt(5)
	fmov d2, 1.0
	fadd d1, d0, d2 // d1 <- 1 + sqrt(5)
	fmov d2, 2.0
	fdiv d1, d1, d2 // d1 <- phi = (1 + sqrt(5)) / 2

	// Start a for loop to compute phi ^ n
	subs w1, w0, #1 // w1 is the loop counter (we start at n-1 and we skip the loop
	beq end_fibinet // if n-1 == 0

	loop_exponent_fibinet:
	fmul d1, d1, d1
	subs w1, w1, #1
	bne loop_exponent_fibinet

	end_fibinet:
	fdiv d0, d1, d0	
	fcvtzs x0, d0 
	ret

	


	
