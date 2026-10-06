# Un jeu en assembleur avec libgfx

Ce répertoire fournit **libgfx**, une bibliothèque C minimale pour dessiner
dans le terminal et lire le clavier, pensée pour être appelée depuis
l'assembleur, ainsi qu'un niveau et une implémentation de référence en C
d'un Lode Runner simplifié. L'exercice consiste à écrire le jeu en
assembleur dans `x86_64/jeu.S` ou `aarch64/jeu.S` (`make jeu`).

## Fichiers

| Fichier | Rôle |
|---|---|
| `gfx.h`, `gfx.c`, `gfx_consts.h` | libgfx; `gfx_consts.h` ne contient que des `#define` et s'inclut depuis un `.S` |
| `demo.c`, `x86_64/demo.S`, `aarch64/demo.S` | le même programme minimal en C et dans les deux assembleurs: un bloc déplacé aux flèches |
| `level1.txt` | le niveau, un caractère par case |
| `mklevel.py` | engendre `level1.h` (pour le C) et `level1.inc` (pour l'assembleur, des `.ascii`) |
| `lode.c` | la référence en C du jeu, étapes 1 à 5 |

`make` compile `demo_c`, `demo_asm` et `lode`; `make run` lance `lode`.
Sous Windows, voir [WSL2.md](../WSL2.md).

## L'API de libgfx

Toutes les fonctions suivent l'ABI C de la machine. Les arguments entiers
et pointeurs vont dans `rdi, rsi, rdx, rcx, r8, r9` (x86-64) ou `x0` à
`x5` (AArch64), le résultat revient dans `rax` ou `x0`. Un appel détruit les
registres *caller-saved*: ce qui doit survivre va dans `rbx, r12` à `r15`
ou `x19` à `x28`, ou en mémoire. Sous macOS les symboles portent un
préfixe `_` (voir la macro `C()` dans les `demo.S`).

```c
int  gfx_open(int w, int h);        // écran de w x h cellules, 0 si ok
void gfx_close(void);
void gfx_clear(int color);
void gfx_put(int x, int y, int ch, int color);
void gfx_rect(int x, int y, int w, int h, int ch, int color);
void gfx_text(int x, int y, const char *s, int color);
void gfx_present(void);             // rien n'est visible avant
int  gfx_key(void);                 // ASCII, GFX_KEY_UP/DOWN/LEFT/RIGHT, ou -1
void gfx_sleep(int ms);
long gfx_ticks(void);               // ms depuis gfx_open
int  gfx_rand(int n);               // dans [0, n)
void gfx_blit(int x, int y, const unsigned char *sprite);
void gfx_map(int x, int y, const char *map, int w, int h, const unsigned char *tiles);
```

Couleurs: `GFX_BLACK` à `GFX_WHITE` (0 à 7), (0, 0) en haut à gauche.

### Sprites

Un sprite est une suite d'octets: largeur, hauteur, puis pour chaque
cellule, ligne par ligne, une paire (caractère, couleur). Un caractère 0 est
transparent.

```asm
joueur: .byte 2, 1,  '(', GFX_GREEN,  ')', GFX_GREEN
```

### Cartes et tuiles

Une carte est un tableau de `w * h` caractères, un par case, ligne par ligne:
c'est exactement le contenu de `level1.inc`. `gfx_map` dessine chaque case
avec une tuile de `GFX_TILE_W` x `GFX_TILE_H` cellules (2 x 1: deux
cellules côte à côte, ce qui donne des cases à peu près carrées). La table
des tuiles associe un caractère de la carte à sa tuile, et se termine par un
octet 0:

```asm
tuiles:
    .byte ' ', ' ', GFX_BLACK, ' ', GFX_BLACK     // vide, et tuile par défaut
    .byte '#', '#', GFX_RED,   '#', GFX_RED       // brique
    .byte 'H', '|', GFX_CYAN,  '|', GFX_CYAN      // échelle
    .byte 0
```

La case `(i, j)` de la carte est dessinée en `(x + 2*i, y + j)`: pour
dessiner un sprite sur une case, multiplier l'abscisse par 2.

## Le niveau

`level1.txt`, 28 cases de large sur 16 de haut:

| Caractère | Case |
|---|---|
| ` ` | vide |
| `#` | brique, creusable |
| `@` | béton, indestructible |
| `H` | échelle |
| `-` | barre, à laquelle on se suspend |
| `$` | or |
| `S` | échelle de sortie, invisible tant qu'il reste de l'or |
| `&` | position de départ du joueur |
| `0` | position de départ d'un ennemi |

Vous pouvez dessiner vos propres niveaux: `python3 mklevel.py monniveau.txt`.

## Les règles, par étapes

`lode.c` implémente les étapes 1 à 5. Chaque étape est une ou deux
fonctions de 10 à 30 lignes, testable seule: faites de même en assembleur.

1. **Niveau et déplacement.** Copier le niveau en mémoire, trouver le
   départ. À chaque pas: dessiner la carte, le joueur, le score. Flèches
   gauche et droite: avancer si la case visée n'est pas solide.
2. **Gravité.** Le joueur a un appui s'il est sur une échelle ou une barre,
   ou si la case dessous est solide ou une échelle. Sinon il descend d'une
   case par pas et ne répond plus aux commandes.
3. **Échelles et barres.** Haut: monter si on est sur une échelle. Bas:
   descendre si la case dessous n'est pas solide, ce qui permet aussi de
   lâcher une barre.
4. **Or et score.** Entrer sur une case `$` la vide et ajoute 100 points.
   Quand il ne reste plus d'or, les `S` deviennent des échelles. Atteindre
   la ligne du haut gagne. Afficher le score demande de convertir un entier
   en chaîne: écrivez `itoa`.
5. **Creuser.** `z` et `x` creusent la brique en diagonale basse, à gauche
   ou à droite, si la case à côté est libre. Le trou se rebouche après 30
   pas: il faut une liste des trous ouverts avec leur compte à rebours. Un
   joueur dans un trou qui se rebouche perd une vie.
6. **Ennemis.** À chaque pas, chaque ennemi réduit sa distance au joueur:
   horizontalement si possible, sinon par l'échelle la plus proche. Il tombe
   dans les trous, y reste quelques pas, en ressort, ou y est enterré et
   réapparaît en haut. Le toucher coûte une vie.
7. **Niveaux.** Plusieurs niveaux, le suivant quand on sort par le haut.

## Boucle de jeu

Un pas toutes les 120 ms, quel que soit le temps de dessin: on note
l'instant du prochain pas et on dort jusqu'à lui (`gfx_ticks`,
`gfx_sleep`). Les touches sont lues en début de pas; on ne garde que la
dernière pour ne pas accumuler de retard.

Le terminal ne signale pas le relâchement d'une touche: maintenir une flèche
produit des répétitions après un délai initial, réglé par le système. Un jeu
où chaque appui déplace d'une case s'en accommode bien.

## Déboguer un programme qui prend le terminal

`gdb` et `lldb` partagent le terminal avec le jeu, ce qui le rend
inutilisable. Lancez le jeu dans un terminal, et le débogueur dans un autre
en s'attachant au processus: `gdb -p $(pgrep jeu)` ou `lldb -p $(pgrep
jeu)`. Ou plus simplement: écrivez chaque fonction d'abord dans un petit
programme de test qui affiche des valeurs avec `printf`, sans libgfx.
