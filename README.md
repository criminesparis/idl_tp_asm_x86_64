# Travaux pratiques: assembleur x86-64 et AArch64

Chaque exercice existe pour les deux architectures que l'on trouve sur vos
machines: **x86-64** (PC sous Linux ou WSL2, anciens Mac Intel) et
**AArch64** (Mac Apple Silicon, Raspberry Pi, Linux arm64). Le `Makefile`
de chaque exercice détecte votre machine et compile le bon source.

- Petit tutoriel GDB: <https://perso.ens-lyon.fr/daniel.hirschkoff/C_Caml/docs/doc_gdb.pdf>
- Cheat Sheet x86-64 du [cours CS33](https://cs0330-fall2024.github.io) de Tom Doeppner (Brown): <https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf>
- Liste des instructions x86-64 de Félix Cloutier: <https://www.felixcloutier.com/x86/>
- Arm A64 Instruction Set Architecture: <https://developer.arm.com/documentation/ddi0602/latest/>
- Convention d'appel AArch64 (AAPCS64): <https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst>
- Compiler Explorer, pour voir ce que produit un compilateur sur les deux
  architectures: <https://godbolt.org>

## Installation

- **Linux** (Debian, Ubuntu): `sudo apt install build-essential gdb`.
- **Windows**: installer WSL2 en suivant [WSL2.md](WSL2.md), puis comme Linux.
- **macOS**: installer les outils en ligne de commande de Xcode avec
  `xcode-select --install`. Le débogueur est `lldb`, pas `gdb`.

Pour travailler aussi sur l'*autre* architecture que celle de votre machine:

- **Mac Apple Silicon**: Rosetta exécute les binaires x86-64. Installez-le
  avec `softwareupdate --install-rosetta`, puis `make ARCH=x86_64`.
- **Linux x86-64**: compilation croisée et émulation:
  `sudo apt install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user`,
  puis `make ARCH=aarch64`. La cible `make run` lance le binaire sous
  `qemu-aarch64`.
- **Docker** (toutes machines): `docker run --rm -it --platform linux/arm64
  -v "$PWD":/w -w /w gcc:14` (ou `linux/amd64`) donne un Linux de
  l'architecture voulue avec gcc et make.

## Organisation d'un exercice

```
0001_hello_world_syscall/
├── Makefile          inclut ../common.mk, choisit $(ARCH)/hello.S
├── x86_64/hello.S    version x86-64, syntaxe AT&T
└── aarch64/hello.S   version AArch64
```

- `make` compile pour votre machine, `make run` exécute, `make info` affiche
  ce qui a été détecté, `make ARCH=x86_64` ou `make ARCH=aarch64` force
  l'architecture.
- Les sources ont l'extension `.S` (majuscule): ils passent par le
  préprocesseur C. Les différences entre Linux et macOS (préfixe `_` des
  symboles, numéros d'appels système, syntaxe des adresses relatives au
  `pc`) sont isolées dans des `#ifdef __APPLE__`.
- [`common.mk`](common.mk) contient la détection de la machine et le choix
  des outils.

## Déboguer

| | Linux (gdb) | macOS (lldb) |
|---|---|---|
| Lancer | `gdb ./prog` | `lldb ./prog` |
| Point d'arrêt | `b main` | `b main` |
| Exécuter | `run` / `r` | `run` / `r` |
| Pas à pas (instruction) | `stepi` / `si` | `si` |
| Passer un appel | `nexti` / `ni` | `ni` |
| Continuer | `c` | `c` |
| Registres | `info registers` | `register read` |
| Un registre | `p $rax` / `p $x0` | `register read rax` / `register read x0` |
| Désassembler | `x/10i $pc` | `disassemble -p` |
| Mémoire | `x/4gx $rsp` | `memory read -fx -s8 -c4 $sp` |
| Pile d'appels | `bt` | `bt` |
| Désassembler un binaire | `objdump -d prog` | `otool -tv prog` |

## Exemples

1. [`0000_hello_world_c`](0000_hello_world_c): "Hello, world!" en C, pour
   la chaîne de compilation.
2. [`0001_hello_world_syscall`](0001_hello_world_syscall): "Hello, world!"
   par appels système, sans libc. Comparez les deux sources: mêmes étapes,
   registres et numéros différents. Les numéros changent aussi entre Linux
   et macOS.
3. [`0002_hello_world_libc`](0002_hello_world_libc): appel de `printf`.
   Première rencontre avec la convention d'appel: alignement de la pile,
   sauvegarde de `lr` sur AArch64.
4. [`0003_argv`](0003_argv): parcours des arguments de la ligne de commande,
   avec des registres sauvés par l'appelé.

## Exercices

La résolution de ces exercices doit être rendue sous la forme d'un _patch_
sur ce dépôt Git obtenu avec [`git diff`](https://git-scm.com/docs/git-diff),
envoyé à votre enseignant par email. Ne pas inclure de fichiers binaires
(exécutables, fichiers objets). Chaque exercice est à faire pour
l'architecture de votre machine; le faire pour la seconde est un bonus.

### Exercice 1: maximum de trois entiers

1. Dans [`0004_max3`](0004_max3), compléter la fonction `max3` (dans
   `x86_64/max3.S` ou `aarch64/max3.S`) pour qu'elle calcule le maximum de
   trois entiers. Sans branchement: avec
   [`cmov`](https://www.felixcloutier.com/x86/cmovcc) sur x86-64, avec
   `csel` sur AArch64.
2. Écrire une variante où les paramètres sont passés en ligne de commande.

### Exercice 2: implémentation de l'algorithme d'Euclide (PGCD)

Coder en assembleur l'équivalent du [programme Python](0005_gcd/gcd.py)
suivant, avec un `Makefile` sur le modèle des exemples:

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

### Exercice 3: calcul d'un terme arbitraire de la suite de Fibonacci

Implémenter en assembleur les trois variantes de [`0006_fib/fib.py`](0006_fib/fib.py):

1. l'[algorithme récursif naïf](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Algorithme_récursif_naïf),
   qui oblige à construire un cadre de pile et à sauver des registres;
2. l'[algorithme itératif](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Algorithme_polynomial);
3. la [formule de Binet](https://fr.wikipedia.org/wiki/Suite_de_Fibonacci#Avec_la_formule_de_Binet),
   en flottant: registres `xmm` ou `d`, et appel de `sqrt` de la libm.

### Exercice 4: un jeu dans le terminal

[`0007_jeu`](0007_jeu) fournit **libgfx**, une bibliothèque C minimale
pour dessiner dans le terminal et lire le clavier, conçue pour être appelée
depuis l'assembleur, avec des sprites et des cartes de tuiles. Il fournit
aussi un niveau de **Lode Runner** et une implémentation de référence en C
des cinq premières règles du jeu (`lode.c`). Tout est décrit dans
[`0007_jeu/README.md`](0007_jeu/README.md).

Écrire le jeu en assembleur dans `$(ARCH)/jeu.S` (`make jeu`), en suivant
les étapes du README: niveau et déplacement, gravité, échelles et barres,
or et score, creuser, puis les ennemis. Les étapes 1 à 4 sont attendues en
séance; les suivantes font l'objet du projet. Attendu dans tous les cas:

- une boucle de jeu à pas fixe (`gfx_ticks`, `gfx_sleep`);
- l'état du jeu en mémoire (le niveau copié, les trous), pas seulement dans
  des registres;
- une fonction par règle, qui respecte la convention d'appel: sauvegarde des
  registres, pile alignée;
- le score affiché, donc un `itoa` écrit par vous.

Le mode script de `lode.c` (`./lode RRRRzLq`) permet de comparer votre
version à la référence sur une même séquence de touches: implémentez-le
aussi, c'est un bon premier test.
