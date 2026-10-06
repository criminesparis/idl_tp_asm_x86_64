/* lode.c: référence en C d'un Lode Runner minimal sur libgfx.
 *
 * Sert de spécification pour la version en assembleur: une fonction par
 * règle, un état en mémoire (le niveau, le joueur, les trous), une boucle à
 * pas fixe. Étapes réalisées: 1 niveau et déplacement, 2 gravité,
 * 3 échelles et barres, 4 or et score, 5 creuser. Restent à faire: 6 les
 * ennemis (ils sont dessinés mais immobiles), 7 la sortie et le niveau
 * suivant (la sortie apparaît, mais il n'y a qu'un niveau).
 *
 * Touches: flèches, z creuser à gauche, x creuser à droite, q quitter.
 *
 * Mode script, pour tester sans clavier: ./lode LLRRUDzxq rejoue une touche
 * par pas (L, R, U, D pour les flèches), puis dort. Pratique pour comparer
 * votre version assembleur à celle-ci sur une même séquence. */
#include "gfx.h"
#include "level1.h"
#include <stdio.h>
#include <string.h>

#define TICK_MS     120             /* durée d'un pas de jeu */
#define HOLE_TICKS  30              /* un trou se rebouche après 30 pas */
#define MAX_HOLES   16
#define MAX_ENEMIES 8
#define ORIGIN_X    0
#define ORIGIN_Y    1               /* la ligne 0 de l'écran affiche le score */

/* --- État du jeu ------------------------------------------------------ */

static char level[LEVEL_H][LEVEL_W];        /* copie modifiable du niveau */
static int  px, py;                         /* position du joueur, en cases */
static int  start_x, start_y;
static int  score, gold_left, lives = 3;
static struct { int x, y, timer; } holes[MAX_HOLES];
static int  nholes;
static struct { int x, y; } enemies[MAX_ENEMIES];
static int  nenemies;

/* --- Graphismes: formats lisibles en .byte depuis l'assembleur -------- */

static const unsigned char tiles[] = {
    ' ', ' ', GFX_BLACK,  ' ', GFX_BLACK,     /* vide (et première tuile: défaut) */
    '#', '#', GFX_RED,    '#', GFX_RED,       /* brique, creusable */
    '@', '@', GFX_WHITE,  '@', GFX_WHITE,     /* béton */
    'H', '|', GFX_CYAN,   '|', GFX_CYAN,      /* échelle */
    '-', '-', GFX_YELLOW, '-', GFX_YELLOW,    /* barre */
    '$', '$', GFX_YELLOW, ' ', GFX_BLACK,     /* or */
    'S', ' ', GFX_BLACK,  ' ', GFX_BLACK,     /* sortie, cachée */
    0
};
static const unsigned char player_sprite[] = { 2, 1, '(', GFX_GREEN,   ')', GFX_GREEN };
static const unsigned char enemy_sprite[]  = { 2, 1, '{', GFX_MAGENTA, '}', GFX_MAGENTA };

/* --- Règles ----------------------------------------------------------- */

static char at(int x, int y)
{
    if (x < 0 || x >= LEVEL_W || y < 0 || y >= LEVEL_H) return '@';
    return level[y][x];
}
static int solid(char c)  { return c == '#' || c == '@'; }
static int ladder(char c) { return c == 'H'; }
static int rope(char c)   { return c == '-'; }

/* Le joueur a un appui: sur une échelle ou une barre, ou au-dessus d'une
 * case solide ou d'une échelle. Sinon il tombe. */
static int standing(void)
{
    char here = at(px, py), below = at(px, py + 1);
    return ladder(here) || rope(here) || solid(below) || ladder(below);
}

static void load_level(void)
{
    gold_left = nholes = nenemies = 0;
    for (int y = 0; y < LEVEL_H; y++)
        for (int x = 0; x < LEVEL_W; x++) {
            char c = level_data[y][x];
            if (c == '&') { start_x = x; start_y = y; c = ' '; }
            else if (c == '0') {
                if (nenemies < MAX_ENEMIES) { enemies[nenemies].x = x; enemies[nenemies].y = y; nenemies++; }
                c = ' ';
            }
            else if (c == '$') gold_left++;
            level[y][x] = c;
        }
    px = start_x; py = start_y;
}

static void die(void)
{
    lives--;
    px = start_x; py = start_y;
}

/* Étape 4: ramasser l'or; quand il n'en reste plus, la sortie apparaît. */
static void collect(void)
{
    if (at(px, py) != '$') return;
    level[py][px] = ' ';
    score += 100;
    if (--gold_left == 0)
        for (int y = 0; y < LEVEL_H; y++)
            for (int x = 0; x < LEVEL_W; x++)
                if (level[y][x] == 'S') level[y][x] = 'H';
}

/* Étapes 1 et 3: déplacements commandés, seulement quand on a un appui. */
static void move_left_right(int dx)
{
    if (!solid(at(px + dx, py))) px += dx;
}
static void move_up(void)
{
    if (ladder(at(px, py)) && !solid(at(px, py - 1))) py--;
}
static void move_down(void)
{
    if (!solid(at(px, py + 1))) py++;    /* échelle, ou lâcher une barre */
}

/* Étape 5: creuser la brique en diagonale basse, si rien ne gêne à côté. */
static void dig(int dir)
{
    int x = px + dir, y = py + 1;
    if (at(x, y) != '#' || solid(at(x, py)) || nholes >= MAX_HOLES) return;
    level[y][x] = ' ';
    holes[nholes].x = x; holes[nholes].y = y; holes[nholes].timer = HOLE_TICKS;
    nholes++;
}

static void update_holes(void)
{
    for (int i = 0; i < nholes; ) {
        if (--holes[i].timer > 0) { i++; continue; }
        level[holes[i].y][holes[i].x] = '#';
        if (px == holes[i].x && py == holes[i].y) die();   /* enterré */
        holes[i] = holes[--nholes];                          /* retire l'entrée */
    }
}

/* --- Affichage -------------------------------------------------------- */

static void draw(const char *message)
{
    char hud[80];
    gfx_clear(GFX_BLACK);
    gfx_map(ORIGIN_X, ORIGIN_Y, &level[0][0], LEVEL_W, LEVEL_H, tiles);
    for (int i = 0; i < nenemies; i++)
        gfx_blit(ORIGIN_X + GFX_TILE_W * enemies[i].x, ORIGIN_Y + enemies[i].y, enemy_sprite);
    gfx_blit(ORIGIN_X + GFX_TILE_W * px, ORIGIN_Y + py, player_sprite);
    if (message)
        snprintf(hud, sizeof hud, "%s", message);
    else
        snprintf(hud, sizeof hud, "Score %d  Or %d  Vies %d   fleches, z/x: creuser, q: quitter",
                 score, gold_left, lives);
    gfx_text(0, 0, hud, GFX_WHITE);
    gfx_present();
}

/* Dernière touche en attente, pour ne pas accumuler de retard. */
static const char *script;                  /* mode script: touches à rejouer */
static int last_key(void)
{
    if (script) {
        if (!*script) return GFX_KEY_NONE;
        switch (*script++) {
        case 'L': return GFX_KEY_LEFT;
        case 'R': return GFX_KEY_RIGHT;
        case 'U': return GFX_KEY_UP;
        case 'D': return GFX_KEY_DOWN;
        default:  return script[-1];
        }
    }
    int k, last = GFX_KEY_NONE;
    while ((k = gfx_key()) != GFX_KEY_NONE) last = k;
    return last;
}

/* --- Boucle de jeu ---------------------------------------------------- */

int main(int argc, char **argv)
{
    if (argc > 1) script = argv[1];
    load_level();
    if (gfx_open(GFX_TILE_W * LEVEL_W, LEVEL_H + ORIGIN_Y) < 0) return 1;
    long next = gfx_ticks();
    const char *end = NULL;
    for (;;) {
        int k = last_key();
        if (k == 'q') break;
        if (standing()) {                       /* commandes */
            if (k == GFX_KEY_LEFT)  move_left_right(-1);
            if (k == GFX_KEY_RIGHT) move_left_right(+1);
            if (k == GFX_KEY_UP)    move_up();
            if (k == GFX_KEY_DOWN)  move_down();
            if (k == 'z')           dig(-1);
            if (k == 'x')           dig(+1);
        }
        if (!standing()) py++;                  /* étape 2: gravité, une case par pas */
        collect();
        update_holes();
        if (lives < 0) end = "Perdu. q pour quitter";
        if (gold_left == 0 && py == 0) end = "Gagne! q pour quitter";
        draw(end);
        if (end) { while (last_key() != 'q') gfx_sleep(50); break; }
        if (script && !*script) { gfx_sleep(300); break; }   /* fin du script */
        next += TICK_MS;                        /* pas fixe, quel que soit le temps de dessin */
        long wait = next - gfx_ticks();
        if (wait > 0) gfx_sleep((int)wait);
    }
    gfx_close();
    printf("Score final: %d\n", score);
    return 0;
}
