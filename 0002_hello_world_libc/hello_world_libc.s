    .global main

    .text
main:
    push %rbx
    mov     $msg, %rdi
    call    printf
    pop %rbx
    ret

    .data
msg:
    .asciz "Hello, world!\n"
