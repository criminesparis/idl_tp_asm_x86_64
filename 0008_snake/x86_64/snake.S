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
    push    %rbx
    push    %r12
    push    %r13
    push    %r14
    push    %r15

    mov     $30, %r12d              # x
    mov     $10, %r13d              # y

    mov     $2, %r14d
    mov     $0, %r15d

    mov     $60, %edi
    mov     $20, %esi
    call    C(gfx_open) 



    test    %eax, %eax
    jnz     .Lfail

.Lloop:
    mov     $GFX_BLACK, %edi
    call    C(gfx_clear)

    mov     $0, %edi             # gfx_rect(x, y, 2, 1, '#', GFX_GREEN)
    mov     $1, %esi
    mov     $60, %edx
    mov     $20, %ecx
    mov     $'.', %r8d
    mov     $GFX_BLUE, %r9d
    call    C(gfx_rect)


    mov     %r12d, %edi             # gfx_rect(x, y, 2, 1, '#', GFX_GREEN)
    mov     %r13d, %esi
    mov     $1, %edx
    mov     $1, %ecx
    mov     $'[', %r8d
    mov     $GFX_GREEN, %r9d
    call    C(gfx_rect)

    mov     %r12d, %edi
    mov     %r13d, %esi
    inc     %edi
    mov     $1, %edx
    mov     $1, %ecx
    mov     $']', %r8d
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
    cmp     $GFX_KEY_LEFT, %eax
    jne     1f
    cmp     $2, %r14d
    je     4f
    mov     $-2, %r14d
    mov     $0, %r15d

1:  cmp     $GFX_KEY_RIGHT, %eax
    jne     2f
    cmp     $-2, %r14d
    je     4f
    mov     $2, %r14d
    mov     $0, %r15d

2:  cmp     $GFX_KEY_UP, %eax
    jne     3f
    cmp     $1, %r15d
    je     4f
    mov     $-1, %r15d
    mov     $0, %r14d

3:  cmp     $GFX_KEY_DOWN, %eax
    jne     4f
    cmp     $-1, %r15d
    je     4f
    mov     $1, %r15d
    mov     $0, %r14d

4:  mov     $150, %edi
    call    C(gfx_sleep)

    add     %r14d, %r12d
    add     %r15d, %r13d
    
    #test des collisions de la tête
    cmp     $0, %r12d
    jl      .Llose
    cmp     $60, %r12d
    jge      .Llose
    cmp     $0, %r13d
    jle      .Llose
    cmp     $20, %r13d
    jge      .Llose

    jmp     .Lloop





.Llose:

    xor     %edi, %edi              # gfx_text(0, 0, aide, GFX_WHITE)
    xor     %esi, %esi
    lea     death(%rip), %rdx
    mov     $GFX_WHITE, %ecx
    call    C(gfx_text)

    call    C(gfx_present)

    mov     $150, %edi
    call    C(gfx_sleep)
    call    C(gfx_key)
    cmp     $'q', %eax
    je      .Lquit
    jmp .Llose

.Lquit:
    call    C(gfx_close)
    xor     %eax, %eax
    jmp     .Lret
.Lfail:
    mov     $1, %eax
.Lret:
    pop     %r13
    pop     %r12
    pop     %r14
    pop     %r15
    pop     %rbx
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
aide:
    .asciz  "fleches: deplacer, q: quitter"
death:
    .asciz  "you died. press q to quit    "
