// "Hello, world!" en appelant printf de la libc. AArch64.
// Le programme commence à main, appelé par le code de démarrage de la libc.
//
// Convention AAPCS64: 1er argument dans x0, adresse de retour dans x30 (lr),
// que bl écrase: une fonction qui appelle une autre fonction doit sauver
// lr (et fp, x29) sur la pile, alignée sur 16 octets.
// Sous macOS les symboles C ont un préfixe "_" et les arguments d'une
// fonction variadique comme printf vont TOUJOURS sur la pile, pas dans
// x1..x7: ici il n'y en a aucun, le code est donc identique.

#ifdef __APPLE__
# define C(sym) _##sym
    .macro ADDR reg, sym
    adrp    \reg, \sym@PAGE
    add     \reg, \reg, \sym@PAGEOFF
    .endm
#else
# define C(sym) sym
    .macro ADDR reg, sym
    adrp    \reg, \sym
    add     \reg, \reg, :lo12:\sym
    .endm
#endif

    .text
    .globl C(main)
C(main):
    stp     x29, x30, [sp, #-16]!   // empile fp et lr, sp -= 16
    mov     x29, sp
    ADDR    x0, msg
    bl      C(printf)
    mov     w0, #0                  // valeur de retour de main: 0
    ldp     x29, x30, [sp], #16     // dépile fp et lr, sp += 16
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
msg:
    .asciz  "Hello, world!\n"
