# "Hello, world!" par appels système directs, sans libc. x86-64, syntaxe AT&T.
#
# Linux : write = 1, exit = 60 (arch/x86/entry/syscalls/syscall_64.tbl)
# macOS : write = 0x2000004, exit = 0x2000001 (classe BSD 2 << 24, numéros
#         dans bsd/kern/syscalls.master du noyau XNU)
# Dans les deux cas: numéro dans %rax, arguments dans %rdi, %rsi, %rdx,
# instruction syscall; %rcx et %r11 sont détruits.

#ifdef __APPLE__
# define SYS_write 0x2000004
# define SYS_exit  0x2000001
#else
# define SYS_write 1
# define SYS_exit  60
#endif

    .text
    .globl _start
_start:
    mov     $SYS_write, %rax
    mov     $1, %rdi                # 1 = sortie standard
    lea     msg(%rip), %rsi         # adresse de la chaîne, relative à %rip
    mov     $len, %rdx
    syscall

    mov     $SYS_exit, %rax
    xor     %rdi, %rdi              # code de retour 0
    syscall

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
msg:
    .ascii  "Hello, world!\n"
    len = . - msg                   # longueur calculée par l'assembleur
