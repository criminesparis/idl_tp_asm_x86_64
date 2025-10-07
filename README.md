# Travaux pratiques: assembleur x86-64

- Petit tutoriel GDB: <https://perso.ens-lyon.fr/daniel.hirschkoff/C_Caml/docs/doc_gdb.pdf>
- Cheat Sheet: <https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf>

## Exemple: "Hello, world!" en C

<0000_hello_world_c>


## 1. Maximum de trois entiers

Compléter la fonction `max3` pour qu'elle calcule le maximum de trois entiers. Vous pouvez par exemple utiliser l'instruction `cmovl`.

<0000_hello_world_c>


## 2. Algorithme d'Euclide (PGCD)

Coder en Assembleur l'équivalent du programme Python suivant:

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

## 3. Fibonacci

Écrire un programme qui calcule récursivement la fonction de Fibonacci sur l'argument entier passé en ligne de commande.
