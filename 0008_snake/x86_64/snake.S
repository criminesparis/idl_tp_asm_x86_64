# Même programme que demo.c, en assembleur x86-64 (syntaxe AT&T).
# Convention System V AMD64: arguments dans %rdi, %rsi, %rdx, %rcx, %r8, %r9;
# résultat dans %rax; %rbx, %r12 à %r15 sauvés par l'appelé.
# La position (x, y) est gardée dans %r12 et %r13, qui survivent aux appels.

#include "../gfx_consts.h"

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)
C(main):
    push    %rbx                    # 3 push: la pile reste alignée sur 16
    push    %r12
    push    %r13
    mov     $30, %r12d              # x
    mov     $10, %r13d              # y

    mov     $60, %edi
    mov     $20, %esi
    call    C(gfx_open)
    test    %eax, %eax
    jnz     .Lfail

.Lloop:
    mov     $GFX_BLACK, %edi
    call    C(gfx_clear)

    mov     %r12d, %edi             # gfx_rect(x, y, 2, 1, '#', GFX_GREEN)
    mov     %r13d, %esi
    mov     $1, %edx
    mov     $1, %ecx
    mov     $'#', %r8d
    mov     $GFX_GREEN, %r9d
    call    C(gfx_rect)

    xor     %edi, %edi              # gfx_text(0, 0, aide, GFX_WHITE)
    xor     %esi, %esi
    lea     aide(%rip), %rdx
    mov     $GFX_WHITE, %ecx
    call    C(gfx_text)



    call    C(gfx_present)

    call    C(gfx_key)              # k dans %eax
    cmp     $'q', %eax
    je      .Lquit
    cmp     $GFX_KEY_NONE, %eax
    je      0f
    mov     %eax, %r14d
0:  cmp     $GFX_KEY_LEFT, %r14d
    jne     1f
    cmp     $1, %r13d
    jle     .Lquit
    dec     %r12d
1:  cmp     $GFX_KEY_RIGHT, %r14d
    jne     2f
    cmp     $59, %r12d
    jge     .Lquit
    inc     %r12d
2:  cmp     $GFX_KEY_UP, %r14d
    jne     3f
    cmp     $1, %r13d
    jle     .Lquit
    dec     %r13d
3:  cmp     $GFX_KEY_DOWN, %r14d
    jne     4f
    cmp     $19, %r13d
    jge     .Lquit
    inc     %r13d
4:  mov     $100, %edi
    call    C(gfx_sleep)
    jmp     .Lloop

.Lquit:
    call    C(gfx_close)
    xor     %eax, %eax
    jmp     .Lret
.Lfail:
    mov     $1, %eax
.Lret:
    pop     %r13
    pop     %r12
    pop     %rbx
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
aide:
    .asciz  "fleches: deplacer, q: quitter"
