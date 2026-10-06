/* Constantes partagées entre le C et l'assembleur (ce fichier ne contient
 * que des #define, il peut être inclus depuis un .S). */
#ifndef GFX_CONSTS_H
#define GFX_CONSTS_H

/* Couleurs (ANSI): */
#define GFX_BLACK   0
#define GFX_RED     1
#define GFX_GREEN   2
#define GFX_YELLOW  3
#define GFX_BLUE    4
#define GFX_MAGENTA 5
#define GFX_CYAN    6
#define GFX_WHITE   7

/* Touches renvoyées par gfx_key(), en plus des codes ASCII: */
#define GFX_KEY_NONE  (-1)
#define GFX_KEY_UP    256
#define GFX_KEY_DOWN  257
#define GFX_KEY_LEFT  258
#define GFX_KEY_RIGHT 259

/* Taille d'une tuile de gfx_map, en cellules: */
#define GFX_TILE_W 2
#define GFX_TILE_H 1

#endif
