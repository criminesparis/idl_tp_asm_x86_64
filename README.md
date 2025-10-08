# Travaux pratiques: assembleur x86-64

- Petit tutoriel GDB: <https://perso.ens-lyon.fr/daniel.hirschkoff/C_Caml/docs/doc_gdb.pdf>
- Cheat Sheet assembleur x86-64 du [cours CS33](https://cs0330-fall2024.github.io) de Tom Doeppner de l'université Brown : <https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf>
- Liste des instructions x86-64 de Félix Cloutier: <https://www.felixcloutier.com/x86/>

## Exemple 1: "Hello, world!" en C

[`0000_hello_world_c`](0000_hello_world_c)

## Exemple 2: "Hello, world!" avec des appels systèmes

[`0001_hello_world_syscall`](0001_hello_world_syscall)

## Exemple 3: "Hello, world!" avec des appels à la bibliothèque standard du C (libc)

[`0002_hello_world_libc`](0002_hello_world_libc)

## Exemple 4: passage de paramètres en ligne de commande

[`0003_argv`](0003_argv)

## Exercices

La résolution de ces exercices doit être rendue sous la forme d'un _patch_ sur ce dépôt Git obtenu avec [`git diff`](https://git-scm.com/docs/git-diff). Ce patch doit être envoyé à votre enseignant par email. Attention à ne pas inclure dans ce _patch_ des fichiers binaires (exécutables, fichiers objets, ...).

### Exercice 1: maximum de trois entiers

1. Dans le répertoire [004_max3](004_max3), compléter la fonction [`max3`](0004_max3/max3.s) pour qu'elle calcule le maximum de trois entiers. Vous pouvez pour cela vous aider de l'instruction [`cmov`](https://www.felixcloutier.com/x86/cmovcc).
2. Écrire une variante où les paramètres de la fonction `max3` sont passés en ligne de commande.

### Exercice 2: implémentation de l'algorithme d'Euclide (PGCD)

Coder en Assembleur l'équivalent du [programme Python](0005_gcd/gcd.py) suivant:

```python
import sys

def gcd(a, b):
    while a != b:
        if a > b:
            a = a - b
        else:
            b = b - a
    return a

print(gcd(int(sys.argv[1]), int(sys.argv[2])))
```

Comme pour l'exercice précédent, créer un `Makefile` permettant de construire le programme.

### Exercice 3: calcul d'un terme arbitraire de la suite de Fibonacci

L'objectif de cet exercice est d'implémenter plusieurs variantes de l'algorithme de calcul d'un terme de la [suite de Fibonacci](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci):

1. Implémenter l'[algorithme de calcul récursif naïf](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Algorithme_récursif_naïf)
2. Implémenter l'[algorithme de calcul en temps polynomial](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Algorithme_polynomial)
3. Implémenter le calcul avec la [formule de Binet](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Avec_la_formule_de_Binet)

Comme pour l'exercice précédent, créer un `Makefile` permettant de construire les programmes.
