#include "../gfx_consts.h"

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

.data
sprite_body:  .byte 2, 1, 'o', GFX_GREEN, 'o', GFX_GREEN
sprite_apple: .byte 2, 1, '@', GFX_RED,   '@', GFX_RED

# Offsets : UP, RIGHT, DOWN, LEFT
dir_dx: .quad  0,  1,  0, -1
dir_dy: .quad -1,  0,  1,  0

.bss
snake_x:  .skip 800
snake_y:  .skip 800
head_idx: .skip 8
tail_idx: .skip 8
length:   .skip 8
dir:      .skip 8
apple_x:  .skip 8
apple_y:  .skip 8
delay:    .skip 8

.text

.globl spawn_apple
spawn_apple:
    movq $30, %rdi
    call gfx_rand
    movq %rax, apple_x(%rip)

    movq $20, %rdi
    call gfx_rand
    movq %rax, apple_y(%rip)
    ret

.globl init_game
init_game:
    movq $3, length(%rip)
    movq $2, head_idx(%rip)
    movq $0, tail_idx(%rip)
    movq $1, dir(%rip)           
    movq $150, delay(%rip)

    # pos snake
    movq $10, snake_x(%rip)
    movq $10, snake_y(%rip)
    movq $11, snake_x + 8(%rip)
    movq $10, snake_y + 8(%rip)
    movq $12, snake_x + 16(%rip)
    movq $10, snake_y + 16(%rip)

    call spawn_apple
    ret

.globl update_snake
update_snake:
    # Touches
    call gfx_key
    cmpq $GFX_KEY_UP, %rax
    je set_up
    cmpq $GFX_KEY_RIGHT, %rax
    je set_right
    cmpq $GFX_KEY_DOWN, %rax
    je set_down
    cmpq $GFX_KEY_LEFT, %rax
    je set_left
    jmp do_move

set_up:
    movq $0, dir(%rip)
    jmp do_move
set_right:
    movq $1, dir(%rip)
    jmp do_move
set_down:
    movq $2, dir(%rip)
    jmp do_move
set_left:
    movq $3, dir(%rip)

do_move:
    movq head_idx(%rip), %rbx
    movq snake_x(,%rbx,8), %r12
    movq snake_y(,%rbx,8), %r13

    movq dir(%rip), %rcx
    addq dir_dx(,%rcx,8), %r12
    addq dir_dy(,%rcx,8), %r13

    # Check bords
    cmpq $0, %r12
    jl lose
    cmpq $30, %r12
    jge lose
    cmpq $0, %r13
    jl lose
    cmpq $20, %r13
    jge lose

    # Avancer tete
    incq %rbx
    cmpq $100, %rbx
    jne save_head
    movq $0, %rbx

save_head:
    movq %rbx, head_idx(%rip)
    movq %r12, snake_x(,%rbx,8)
    movq %r13, snake_y(,%rbx,8)

    # Check pomme
    cmpq apple_x(%rip), %r12
    jne no_apple
    cmpq apple_y(%rip), %r13
    jne no_apple

    # Mange pomme
    incq length(%rip)
    call spawn_apple
    
    movq delay(%rip), %rax
    subq $5, %rax
    movq %rax, delay(%rip)
    ret

no_apple:
    # Avancer queue
    movq tail_idx(%rip), %rax
    incq %rax
    cmpq $100, %rax
    jne save_tail
    movq $0, %rax
save_tail:
    movq %rax, tail_idx(%rip)
    ret

lose:
    call init_game
    ret

.globl render
render:
    movq $GFX_BLACK, %rdi
    call gfx_clear

    # Dessiner pomme
    movq apple_x(%rip), %rdi
    shlq $1, %rdi
    movq apple_y(%rip), %rsi
    leaq sprite_apple(%rip), %rdx
    call gfx_blit

    # Dessiner snake
    movq tail_idx(%rip), %rbx

loop_render:
    movq snake_x(,%rbx,8), %rdi
    shlq $1, %rdi
    movq snake_y(,%rbx,8), %rsi
    leaq sprite_body(%rip), %rdx
    call gfx_blit

    cmpq head_idx(%rip), %rbx
    je end_render

    incq %rbx
    cmpq $100, %rbx
    jne loop_render
    movq $0, %rbx
    jmp loop_render

end_render:
    call gfx_present
    ret

.globl main
main:
    movq $30, %rdi
    movq $20, %rsi
    call gfx_open

    call init_game

game_loop:
    call update_snake
    call render

    movq delay(%rip), %rdi
    call gfx_sleep

    jmp game_loop

    movq $0, %rax
    ret