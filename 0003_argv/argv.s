# Affiche les arguments passés en ligne de commande, un par ligne.
    .global main

    .text
    # argc -> rdi (int)
    # argv -> rsi (adresse)
main:
    push %rdi  # Sauvegarde les registres utilisés par push
    push %rsi
    sub $8, %rsp  # Alignement du stack (16 octets)

    mov (%rsi), %rdi  # Contenu à l'adresse %rsi dans %rdi
    call puts

    add $8, %rsp  # restauration de %rsp à la valeur préalignée
    pop %rsi  # restauration des registres utilisés par puts
    pop %rdi

    add $8, %rsi  # Déplace l'adresse de 8 octets (élément suivant)
    dec %rdi
    jnz main

    ret
