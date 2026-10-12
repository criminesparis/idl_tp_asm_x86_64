#include "../gfx_consts.h"

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .data
# Sprites du joueur (2 cellules de large, 1 de haut)
sprite_player:
    .byte 2, 1, '(', GFX_GREEN, ')', GFX_GREEN


tiles:
    .byte ' ', ' ', GFX_BLACK, ' ', GFX_BLACK    # Vide
    .byte '#', '#', GFX_RED,   '#', GFX_RED      # Brique
    .byte '@', '[', GFX_WHITE, ']', GFX_WHITE    # Béton
    .byte 'H', '|', GFX_CYAN,  '|', GFX_CYAN     # Échelle
    .byte '-', '-', GFX_YELLOW,'-', GFX_YELLOW   # Barre
    .byte '$', '{', GFX_YELLOW,'}', GFX_YELLOW   # Or
    .byte 0

    .bss
    .lcomm level_map, 448     # 28 * 16 = 448 octets (taille de la carte)
    .lcomm player_x, 8        # Position X (0 à 27)
    .lcomm player_y, 8        # Position Y (0 à 15)
    .lcomm next_tick, 8       # Temps du prochain pas

    .text


    .globl C(init_level)
C(init_level):
    movq    $0, %rcx

.Linit_loop:
    cmpq    $448, %rcx
    jge     .Linit_done

    movb    C(levels_data)(%rcx), %al 
    movb    %al, level_map(%rcx)

    cmpb    $'&', %al                 # Départ joueur
    jne     .Linit_next

    # Position X et Y
    movq    %rcx, %rax
    movq    $28, %rbx
    cqto
    idivq   %rbx
    movq    %rdx, player_x(%rip)
    movq    %rax, player_y(%rip)
    movb    $' ', level_map(%rcx)

.Linit_next:
    incq    %rcx
    jmp     .Linit_loop

.Linit_done:
    ret


C(is_solid):
    cmpq    $0, %rdi
    jl      .Lsolid_true
    cmpq    $28, %rdi
    jge     .Lsolid_true
    cmpq    $0, %rsi
    jl      .Lsolid_true
    cmpq    $16, %rsi
    jge     .Lsolid_true

    imulq   $28, %rsi, %rax
    addq    %rdi, %rax
    movzbq  level_map(%rax), %rax

    cmpb    $'#', %al
    je      .Lsolid_true
    cmpb    $'@', %al
    je      .Lsolid_true

    movq    $0, %rax
    ret

.Lsolid_true:
    movq    $1, %rax
    ret


C(has_support):
    pushq   %rbx
    movq    player_x(%rip), %rdi
    movq    player_y(%rip), %rsi

    imulq   $28, %rsi, %rax
    addq    %rdi, %rax
    movzbq  level_map(%rax), %rbx

    cmpb    $'H', %bl
    je      .Lsupport_true
    cmpb    $'-', %bl
    je      .Lsupport_true

    incq    %rsi
    imulq   $28, %rsi, %rax
    addq    %rdi, %rax
    movzbq  level_map(%rax), %rax

    cmpb    $'H', %al
    je      .Lsupport_true

    call    C(is_solid)
    popq    %rbx
    ret

.Lsupport_true:
    movq    $1, %rax
    popq    %rbx
    ret


C(update_player):
    pushq   %rbx
    pushq   %r12

    call    C(gfx_key)
    movq    %rax, %rbx

    call    C(has_support)
    cmpq    $0, %rax
    je      .Lapply_gravity

    movq    player_x(%rip), %r12

    cmpq    $GFX_KEY_LEFT, %rbx
    je      .Lmove_left
    cmpq    $GFX_KEY_RIGHT, %rbx
    je      .Lmove_right
    jmp     .Lupdate_done

.Lmove_left:
    decq    %r12
    movq    %r12, %rdi
    movq    player_y(%rip), %rsi
    call    C(is_solid)
    cmpq    $0, %rax
    jne     .Lupdate_done
    movq    %r12, player_x(%rip)
    jmp     .Lupdate_done

.Lmove_right:
    incq    %r12
    movq    %r12, %rdi
    movq    player_y(%rip), %rsi
    call    C(is_solid)
    cmpq    $0, %rax
    jne     .Lupdate_done
    movq    %r12, player_x(%rip)
    jmp     .Lupdate_done

.Lapply_gravity:
    movq    player_y(%rip), %rax
    incq    %rax
    movq    %rax, player_y(%rip)

.Lupdate_done:
    popq    %r12
    popq    %rbx
    ret



    .globl C(main)
C(main):
    subq    $8, %rsp

    movq    $28, %rdi
    movq    $16, %rsi
    call    C(gfx_open)

    call    C(init_level)

    call    C(gfx_ticks)
    addq    $120, %rax
    movq    %rax, next_tick(%rip)

.Lmain_loop:
    call    C(update_player)

    movq    $GFX_BLACK, %rdi
    call    C(gfx_clear)

    movq    $0, %rdi
    movq    $0, %rsi
    leaq    level_map(%rip), %rdx
    movq    $28, %rcx
    movq    $16, %r8
    leaq    tiles(%rip), %r9
    call    C(gfx_map)

    movq    player_x(%rip), %rdi
    shlq    $1, %rdi
    movq    player_y(%rip), %rsi
    leaq    sprite_player(%rip), %rdx
    call    C(gfx_blit)

    call    C(gfx_present)

    call    C(gfx_ticks)
    movq    next_tick(%rip), %rcx
    subq    %rax, %rcx
    jle     .Lskip_sleep

    movq    %rcx, %rdi
    call    C(gfx_sleep)

.Lskip_sleep:
    movq    next_tick(%rip), %rax
    addq    $120, %rax
    movq    %rax, next_tick(%rip)

    jmp     .Lmain_loop

    call    C(gfx_close)
    addq    $8, %rsp
    movq    $0, %rax
    ret

.section .note.GNU-stack,"",@progbits