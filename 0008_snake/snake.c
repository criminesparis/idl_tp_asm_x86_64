/* snake.c: référence en C du Snake sur libgfx, à traduire en assembleur.
 *
 * Le serpent avance seul d'une case par pas; les flèches changent sa
 * direction (jamais vers l'arrière); manger la pomme l'allonge d'une case,
 * ajoute 10 points et accélère le jeu; toucher un mur ou son propre corps
 * termine la partie. Le corps est une file circulaire de positions: la tête
 * entre à un bout, la queue sort à l'autre, et grandir consiste à ne pas
 * sortir la queue.
 *
 * Touches: flèches, q quitter. Mode script: ./snake "RRRDDD.LL" rejoue une
 * touche par pas, '.' = aucune touche. La pomme est tirée avec gfx_rand,
 * donc un script ne donne pas toujours la même partie: pour comparer deux
 * programmes, mettre la pomme à une position fixe (voir FIXED_APPLE). */
#include "gfx.h"
#include <stdio.h>
#include <string.h>

#define W        30                 /* grille de W x H cases de 2 x 1 cellules */
#define H        20
#define ORIGIN_Y 1
#define MAX_LEN  (W * H)
#define TICK0_MS 150                /* durée d'un pas au départ */
#define TICK_MIN 60

/* --- État ------------------------------------------------------------- */

static int bx[MAX_LEN], by[MAX_LEN];    /* file circulaire des cases du corps */
static int head, tail, len;             /* indices dans la file, longueur */
static int dx, dy;                      /* direction courante */
static int ax, ay;                      /* la pomme */
static int score, tick_ms, alive = 1;
static const char *script;

static const unsigned char body_sprite[]  = { 2, 1, '[', GFX_GREEN,  ']', GFX_GREEN };
static const unsigned char head_sprite[]  = { 2, 1, '(', GFX_GREEN,  ')', GFX_GREEN };
static const unsigned char apple_sprite[] = { 2, 1, '@', GFX_RED,    ' ', GFX_BLACK };

/* --- Règles ----------------------------------------------------------- */

static int on_body(int x, int y)
{
    for (int i = tail; i != head; i = (i + 1) % MAX_LEN)
        if (bx[i] == x && by[i] == y) return 1;
    return bx[head] == x && by[head] == y;
}

static void place_apple(void)
{
#ifdef FIXED_APPLE
    ax = (ax + 7) % W; ay = (ay + 5) % H;           /* déterministe, pour les tests */
    while (on_body(ax, ay)) { ax = (ax + 1) % W; }
#else
    do { ax = gfx_rand(W); ay = gfx_rand(H); } while (on_body(ax, ay));
#endif
}

static void init(void)
{
    head = tail = 0; len = 1;
    bx[0] = W / 2; by[0] = H / 2;
    dx = 1; dy = 0;
    ax = 3; ay = 3;
    place_apple();
    score = 0; tick_ms = TICK0_MS; alive = 1;
}

/* Un pas: avancer la tête, manger ou raccourcir la queue, détecter la mort. */
static void step(void)
{
    int nx = bx[head] + dx, ny = by[head] + dy;
    if (nx < 0 || nx >= W || ny < 0 || ny >= H) { alive = 0; return; }
    int eat = (nx == ax && ny == ay);
    if (!eat) tail = (tail + 1) % MAX_LEN;          /* la queue avance d'abord */
    else len++;
    if (on_body(nx, ny)) { alive = 0; return; }     /* après le départ de la queue */
    head = (head + 1) % MAX_LEN;
    bx[head] = nx; by[head] = ny;
    if (eat) {
        score += 10;
        if (tick_ms > TICK_MIN) tick_ms -= 5;
        place_apple();
    }
}

static void turn(int ndx, int ndy)
{
    if (ndx == -dx && ndy == -dy && len > 1) return;   /* pas de demi-tour */
    dx = ndx; dy = ndy;
}

/* --- Affichage et clavier -------------------------------------------- */

static void draw(const char *message)
{
    char hud[80];
    gfx_clear(GFX_BLACK);
    gfx_rect(0, ORIGIN_Y, 2 * W, H, '.', GFX_BLUE);
    for (int i = tail; i != head; i = (i + 1) % MAX_LEN)
        gfx_blit(2 * bx[i], ORIGIN_Y + by[i], body_sprite);
    gfx_blit(2 * bx[head], ORIGIN_Y + by[head], head_sprite);
    gfx_blit(2 * ax, ORIGIN_Y + ay, apple_sprite);
    if (message) snprintf(hud, sizeof hud, "%s", message);
    else snprintf(hud, sizeof hud, "Score %d  Longueur %d   fleches, q: quitter", score, len);
    gfx_text(0, 0, hud, GFX_WHITE);
    gfx_present();
}

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

int main(int argc, char **argv)
{
    if (argc > 1) script = argv[1];
    if (gfx_open(2 * W, H + ORIGIN_Y) < 0) return 1;
    init();
    long next = gfx_ticks();
    for (;;) {
        int k = last_key();
        if (k == 'q') break;
        if (k == GFX_KEY_LEFT)  turn(-1, 0);
        if (k == GFX_KEY_RIGHT) turn(1, 0);
        if (k == GFX_KEY_UP)    turn(0, -1);
        if (k == GFX_KEY_DOWN)  turn(0, 1);
        if (alive) step();
        draw(alive ? NULL : "Perdu. q pour quitter");
        if (!alive) {                           /* attendre q, ou la fin du script */
            while (last_key() != 'q' && !(script && !*script)) gfx_sleep(50);
            break;
        }
        if (script && !*script) { gfx_sleep(300); break; }
        next += tick_ms;
        long wait = next - gfx_ticks();
        if (wait > 0) gfx_sleep((int)wait);
    }
    gfx_close();
    printf("Score final: %d, longueur %d\n", score, len);
    return 0;
}
