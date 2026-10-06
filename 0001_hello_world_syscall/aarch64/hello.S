// "Hello, world!" par appels système directs, sans libc. AArch64 (ARMv8-A).
//
// Linux : numéro dans x8, svc #0, write = 64, exit = 93
//         (include/uapi/asm-generic/unistd.h)
// macOS : numéro dans x16, svc #0x80, write = 4, exit = 1
// Dans les deux cas: arguments dans x0, x1, x2; résultat dans x0.
// Les adresses sont relatives au pc: adrp (page de 4 Ko) + add (bas de
// l'adresse). macOS note la page sym@PAGE, GNU as :lo12:sym.
//
// Les macros sont des macros d'assembleur (.macro), pas du préprocesseur C:
// l'assembleur de macOS prend ";" pour un début de commentaire, on ne peut
// donc pas mettre deux instructions sur une ligne de macro C.

#ifdef __APPLE__
    .macro SYSCALL nr
    mov     x16, \nr
    svc     0x80
    .endm
    .macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
    .endm
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
#endif

    .text
    .globl _start
_start:
    mov     x0, #1                  // 1 = sortie standard
    ADDR    x1, msg
    mov     x2, #len
    SYSCALL SYS_write

    mov     x0, #0                  // code de retour 0
    SYSCALL SYS_exit

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
msg:
    .ascii  "Hello, world!\n"
    len = . - msg
