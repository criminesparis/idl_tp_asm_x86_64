/* libgfx: une bibliothèque minimale de "graphisme" dans le terminal, pensée
 * pour être appelée depuis l'assembleur. Pas de dépendance: codes ANSI et
 * termios, donc Linux, macOS et WSL2.
 *
 * Toutes les fonctions suivent l'ABI C de la machine (System V AMD64 ou
 * AAPCS64): les arguments entiers vont dans rdi, rsi, rdx, rcx, r8 (x86-64)
 * ou x0 à x4 (AArch64), le résultat dans rax ou x0. Sous macOS les symboles
 * portent un préfixe "_". */
#ifndef GFX_H
#define GFX_H

#include "gfx_consts.h"

/* Ouvre une "fenêtre" de w colonnes sur h lignes dans le terminal: mode brut,
 * écran alternatif, curseur caché. Renvoie 0 si tout va bien, -1 sinon. */
int  gfx_open(int w, int h);
/* Rend le terminal dans son état initial. */
void gfx_close(void);

/* Remplit tout l'écran d'espaces de la couleur donnée (fond). */
void gfx_clear(int color);
/* Place le caractère ch de couleur color en (x, y); (0, 0) est en haut à
 * gauche. Hors de l'écran: ignoré. */
void gfx_put(int x, int y, int ch, int color);
/* Rectangle plein de w x h caractères ch. */
void gfx_rect(int x, int y, int w, int h, int ch, int color);
/* Chaîne C terminée par 0, écrite à partir de (x, y). */
void gfx_text(int x, int y, const char *s, int color);
/* Envoie le contenu de l'écran au terminal. Rien n'est visible avant. */
void gfx_present(void);

/* Touche en attente, sans bloquer: un code ASCII, une constante GFX_KEY_*,
 * ou GFX_KEY_NONE (-1) si aucune touche. */
int  gfx_key(void);
/* Attend ms millisecondes. */
void gfx_sleep(int ms);
/* Millisecondes écoulées depuis gfx_open. */
long gfx_ticks(void);
/* Entier pseudo-aléatoire dans [0, n). */
int  gfx_rand(int n);

/* Sprites et tuiles. Formats conçus pour être écrits en .byte depuis
 * l'assembleur, sans structure C.
 *
 * Un sprite est une suite d'octets: largeur w, hauteur h, puis w*h paires
 * (caractère, couleur) ligne par ligne. Un caractère 0 est transparent.
 * Exemple d'un bonhomme de 2 x 1 cellules, vert:
 *   .byte 2, 1,  '(', GFX_GREEN,  ')', GFX_GREEN
 * Dessine le sprite avec son coin haut gauche en (x, y). */
void gfx_blit(int x, int y, const unsigned char *sprite);

/* Une carte (niveau) est un tableau de w*h caractères, ligne par ligne, un
 * caractère par case. Chaque case est dessinée par une tuile de
 * GFX_TILE_W x GFX_TILE_H cellules. La table des tuiles est une suite
 * d'entrées de 1 + 2*GFX_TILE_W*GFX_TILE_H octets: le caractère de la carte,
 * puis les paires (caractère, couleur) de la tuile; elle se termine par un
 * octet 0. Exemple:
 *   .byte '#', '#', GFX_RED, '#', GFX_RED     // brique
 *   .byte ' ', ' ', GFX_BLACK, ' ', GFX_BLACK // vide
 *   .byte 0
 * Dessine la carte avec son coin haut gauche en (x, y): la case (i, j) est
 * dessinée en (x + GFX_TILE_W*i, y + GFX_TILE_H*j). Un caractère absent de
 * la table est dessiné comme la première entrée. */
void gfx_map(int x, int y, const char *map, int w, int h, const unsigned char *tiles);

#endif
