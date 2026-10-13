// int64_t fib_binet(int64_t x)
// AArch64, convention AAPCS64: x -> x0, résultat dans x0.
// Indice: cmp puis csel (sélection conditionnelle), pas de branchement.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib_binet)
C(fib_binet):
    // Calculation of the constant sqrt(5)
    // we save it in the register d0, and this will
    // be use later in the return frame later
    mov x1, #0b101
    scvtf d1, x1
    FSQRT d0, d1

    // Calculation of 1 + sqrt(5)
    mov x1, #0b001
    scvtf d2, x1
    FADD d1, d0, d2

    // Calculation of (1 + sqrt(5))/2
    mov x1, #0b010
    scvtf d2, x1
    FDIV d1, d1, d2

    // check if x0 is zero
    cbz x0, return_zero

    // check if x0 is one 
    cmp x0, #0b001
    b.eq return

    // initialize accumulator d2 = 1.0 and exponent counter x1 = x0
    mov x1, #0b001
    scvtf d2, x1
    mov x1, x0

    b loop

return_zero:
    // return 0 for fib(0)
    mov x0, #0b000
    ret

return:
    // multiply remaining factor: d1 = d1 * d2 (phi^n)
    FMUL d1, d1, d2
    // divide by sqrt(5): d1 = phi^n / sqrt(5)
    FDIV d1, d1, d0
    // round to nearest integer and return in x0
    FCVTNS x0, d1
    ret

loop:
    // if exponent counter == 1, finish exponentiation
    cmp x1, #0b001
    b.eq return

    // test lowest bit to check if exponent is odd or even
    tst x1, #0b001
    b.eq is_even_loop

    b is_odd_loop

is_even_loop:
    // exponent is even: x1 = x1 / 2, base d1 = d1^2
    lsr x1, x1, #0b001
    FMUL d1, d1, d1

    b loop

is_odd_loop:
    // exponent is odd: x1 = x1 - 1, acc d2 = d2 * d1
    sub x1, x1, #0b001
    FMUL d2, d2, d1

    b is_even_loop

