/* sokoban.c: référence en C du Sokoban sur libgfx, à traduire en assembleur.
 *
 * Pousser les caisses ($) sur les cibles (.). Pas de temps réel: le jeu
 * n'avance que sur une touche. Règle unique: on se déplace sur le sol ou
 * une cible; si la case visée contient une caisse et que la case suivante
 * est libre, la caisse avance aussi. Annuler (u) défait le dernier coup,
 * caisse comprise: les coups sont empilés. Un niveau est gagné quand
 * toutes les caisses sont sur des cibles.
 *
 * Touches: flèches, u annuler, r recommencer, n niveau suivant, q quitter.
 * Mode script: ./sokoban "LLURu" rejoue une touche par pas. */
#include "gfx.h"
#include "levels.h"
#include <stdio.h>
#include <string.h>

#define ORIGIN_Y  1
#define MAX_UNDO  1000

/* --- État ------------------------------------------------------------- */

static char board[LEVEL_H][LEVEL_W];    /* murs, sol, cibles: ne change pas */
static char boxes[LEVEL_H][LEVEL_W];    /* 1 si une caisse est sur la case */
static int px, py, level, moves;
static struct { signed char dx, dy, pushed; } undo[MAX_UNDO];
static int nundo;
static const char *script;

static const unsigned char tiles[] = {
    ' ', ' ', GFX_BLACK, ' ', GFX_BLACK,
    '#', '#', GFX_WHITE, '#', GFX_WHITE,
    '.', ' ', GFX_BLACK, '.', GFX_YELLOW,
    0
};
static const unsigned char player_sprite[] = { 2, 1, '(', GFX_GREEN,  ')', GFX_GREEN };
static const unsigned char box_sprite[]    = { 2, 1, '[', GFX_RED,    ']', GFX_RED };
static const unsigned char box_ok_sprite[] = { 2, 1, '[', GFX_YELLOW, ']', GFX_YELLOW };

/* --- Règles ----------------------------------------------------------- */

static void load_level(int n)
{
    level = n; moves = nundo = 0;
    for (int y = 0; y < LEVEL_H; y++)
        for (int x = 0; x < LEVEL_W; x++) {
            char c = levels_data[n][y][x];
            boxes[y][x] = (c == '$' || c == '*');
            if (c == '@' || c == '+') { px = x; py = y; }
            board[y][x] = (c == '.' || c == '*' || c == '+') ? '.' : (c == '#' ? '#' : ' ');
        }
}

static int solved(void)
{
    for (int y = 0; y < LEVEL_H; y++)
        for (int x = 0; x < LEVEL_W; x++)
            if (boxes[y][x] && board[y][x] != '.') return 0;
    return 1;
}

static int free_cell(int x, int y)
{
    return x >= 0 && x < LEVEL_W && y >= 0 && y < LEVEL_H
        && board[y][x] != '#' && !boxes[y][x];
}

/* Un coup: renvoie 1 s'il a eu lieu. */
static int move(int dx, int dy)
{
    int nx = px + dx, ny = py + dy, pushed = 0;
    if (nx < 0 || nx >= LEVEL_W || ny < 0 || ny >= LEVEL_H || board[ny][nx] == '#') return 0;
    if (boxes[ny][nx]) {
        if (!free_cell(nx + dx, ny + dy)) return 0;
        boxes[ny][nx] = 0; boxes[ny + dy][nx + dx] = 1;
        pushed = 1;
    }
    px = nx; py = ny; moves++;
    if (nundo < MAX_UNDO) { undo[nundo].dx = dx; undo[nundo].dy = dy; undo[nundo].pushed = pushed; nundo++; }
    return 1;
}

static void undo_move(void)
{
    if (nundo == 0) return;
    nundo--;
    int dx = undo[nundo].dx, dy = undo[nundo].dy;
    if (undo[nundo].pushed) {                       /* la caisse revient aussi */
        boxes[py + dy][px + dx] = 0;
        boxes[py][px] = 1;
    }
    px -= dx; py -= dy; moves--;
}

/* --- Affichage et clavier -------------------------------------------- */

static void draw(const char *message)
{
    char hud[80];
    gfx_clear(GFX_BLACK);
    gfx_map(0, ORIGIN_Y, &board[0][0], LEVEL_W, LEVEL_H, tiles);
    for (int y = 0; y < LEVEL_H; y++)
        for (int x = 0; x < LEVEL_W; x++)
            if (boxes[y][x])
                gfx_blit(2 * x, ORIGIN_Y + y, board[y][x] == '.' ? box_ok_sprite : box_sprite);
    gfx_blit(2 * px, ORIGIN_Y + py, player_sprite);
    if (message) snprintf(hud, sizeof hud, "%s", message);
    else snprintf(hud, sizeof hud, "Niveau %d/%d  Coups %d   fleches, u: annuler, r: recommencer, q: quitter",
                  level + 1, NLEVELS, moves);
    gfx_text(0, 0, hud, GFX_WHITE);
    gfx_present();
}

static int next_key(void)
{
    if (script) {
        if (!*script) return 'q';
        switch (*script++) {
        case 'L': return GFX_KEY_LEFT;
        case 'R': return GFX_KEY_RIGHT;
        case 'U': return GFX_KEY_UP;
        case 'D': return GFX_KEY_DOWN;
        default:  return script[-1];
        }
    }
    int k;
    while ((k = gfx_key()) == GFX_KEY_NONE) gfx_sleep(20);   /* bloquant: rien ne bouge seul */
    return k;
}

int main(int argc, char **argv)
{
    if (argc > 1) script = argv[1];
    if (gfx_open(2 * LEVEL_W, LEVEL_H + ORIGIN_Y) < 0) return 1;
    load_level(0);
    for (;;) {
        draw(solved() ? "Gagne! n: niveau suivant, q: quitter" : NULL);
        if (script) gfx_sleep(100);
        int k = next_key();
        if (k == 'q') break;
        if (solved()) {
            if (k == 'n' && level + 1 < NLEVELS) load_level(level + 1);
            continue;
        }
        if (k == GFX_KEY_LEFT)  move(-1, 0);
        if (k == GFX_KEY_RIGHT) move(1, 0);
        if (k == GFX_KEY_UP)    move(0, -1);
        if (k == GFX_KEY_DOWN)  move(0, 1);
        if (k == 'u')           undo_move();
        if (k == 'r')           load_level(level);
    }
    int done = solved();
    gfx_close();
    printf("Niveau %d, %d coups, %s\n", level + 1, moves, done ? "resolu" : "non resolu");
    return 0;
}
