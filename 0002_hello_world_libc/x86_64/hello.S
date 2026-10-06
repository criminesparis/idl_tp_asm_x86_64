# "Hello, world!" en appelant printf de la libc. x86-64, syntaxe AT&T.
# Le programme commence à main, appelé par le code de démarrage de la libc.
#
# Convention System V AMD64 (Linux et macOS):
#   1er argument dans %rdi, %rax = nombre de registres vectoriels utilisés
#   par une fonction variadique (0 ici), pile alignée sur 16 octets AVANT
#   l'instruction call. Sous macOS les symboles C ont un préfixe "_".

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)
C(main):
    push    %rbx                    # aligne la pile (8 + 8 = 16) et
                                    # sauve un registre callee-saved
    lea     msg(%rip), %rdi
    xor     %eax, %eax
    call    C(printf)
    pop     %rbx
    xor     %eax, %eax              # valeur de retour de main: 0
    ret

#ifdef __APPLE__
    .section __TEXT,__cstring
#else
    .section .rodata
#endif
msg:
    .asciz  "Hello, world!\n"
