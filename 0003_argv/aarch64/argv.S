// Affiche les arguments passés en ligne de commande, un par ligne.
// AArch64. int main(int argc, char *argv[]): argc -> w0, argv -> x1.
// puts détruit x0..x17: on garde argc et argv dans x19 et x20, sauvés par
// l'appelé, que main doit donc sauver et restaurer avec fp et lr.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)
C(main):
    stp     x29, x30, [sp, #-32]!   // fp, lr
    stp     x19, x20, [sp, #16]     // callee-saved utilisés
    mov     x29, sp
    mov     w19, w0                 // w19 = argc
    mov     x20, x1                 // x20 = argv
1:
    ldr     x0, [x20], #8           // x0 = *argv++ (post-indexé)
    bl      C(puts)
    subs    w19, w19, #1            // argc--, positionne les drapeaux
    b.ne    1b
    mov     w0, #0
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
