    .global _start
 
    .data
msg:
    .ascii  "Hello, world!\n"

    .text
_start:
        mov     $1, %rax  # sys_write
        mov     $1, %rdi
        mov     $msg, %rsi
        mov     $14, %rdx
        syscall

        mov     $60, %rax  # sys_exit
        xor     %rdi, %rdi
        syscall
