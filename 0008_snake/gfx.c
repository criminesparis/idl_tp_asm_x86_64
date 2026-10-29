/* libgfx: voir gfx.h. */
#include "gfx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <time.h>
#include <sys/select.h>

static int W, H;
static unsigned char *cells;    /* W*H caractères */
static unsigned char *colors;   /* W*H couleurs 0..7 */
static struct termios saved;
static int raw_ok;
static struct timespec t0;
static unsigned long rng = 0x9E3779B97F4A7C15UL;

static void out(const char *s) { fputs(s, stdout); }

int gfx_open(int w, int h)
{
    if (w <= 0 || h <= 0 || w > 500 || h > 200) return -1;
    W = w; H = h;
    cells = malloc((size_t)W * H);
    colors = malloc((size_t)W * H);
    if (!cells || !colors) return -1;
    memset(cells, ' ', (size_t)W * H);
    memset(colors, GFX_WHITE, (size_t)W * H);
    if (tcgetattr(STDIN_FILENO, &saved) == 0) {
        struct termios t = saved;
        t.c_lflag &= ~(ICANON | ECHO);  /* touche par touche, sans écho */
        t.c_cc[VMIN] = 0; t.c_cc[VTIME] = 0;
        raw_ok = tcsetattr(STDIN_FILENO, TCSANOW, &t) == 0;
    }
    out("\x1b[?1049h\x1b[?25l\x1b[2J");  /* écran alternatif, curseur caché */
    fflush(stdout);
    clock_gettime(CLOCK_MONOTONIC, &t0);
    rng ^= (unsigned long)t0.tv_nsec;
    return 0;
}

void gfx_close(void)
{
    out("\x1b[0m\x1b[?25h\x1b[?1049l");
    fflush(stdout);
    if (raw_ok) tcsetattr(STDIN_FILENO, TCSANOW, &saved);
    free(cells); free(colors); cells = colors = NULL;
}

void gfx_clear(int color)
{
    if (!cells) return;
    memset(cells, ' ', (size_t)W * H);
    memset(colors, color & 7, (size_t)W * H);
}

void gfx_put(int x, int y, int ch, int color)
{
    if (!cells || x < 0 || y < 0 || x >= W || y >= H) return;
    cells[y * W + x] = (unsigned char)ch;
    colors[y * W + x] = (unsigned char)(color & 7);
}

void gfx_rect(int x, int y, int w, int h, int ch, int color)
{
    for (int j = 0; j < h; j++)
        for (int i = 0; i < w; i++)
            gfx_put(x + i, y + j, ch, color);
}

void gfx_text(int x, int y, const char *s, int color)
{
    for (; *s; s++, x++) gfx_put(x, y, *s, color);
}

void gfx_present(void)
{
    if (!cells) return;
    out("\x1b[H");                      /* curseur en haut à gauche */
    int cur = -1;
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            int c = colors[y * W + x];
            if (c != cur) { printf("\x1b[3%dm", c); cur = c; }
            putchar(cells[y * W + x]);
        }
        if (y < H - 1) putchar('\n');
    }
    fflush(stdout);
}

int gfx_key(void)
{
    fd_set fds; FD_ZERO(&fds); FD_SET(STDIN_FILENO, &fds);
    struct timeval tv = {0, 0};
    if (select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) <= 0) return GFX_KEY_NONE;
    unsigned char c;
    if (read(STDIN_FILENO, &c, 1) != 1) return GFX_KEY_NONE;
    if (c != 0x1b) return c;
    /* Séquence d'échappement d'une flèche: ESC [ A/B/C/D */
    unsigned char seq[2];
    if (read(STDIN_FILENO, &seq[0], 1) != 1 || seq[0] != '[') return 0x1b;
    if (read(STDIN_FILENO, &seq[1], 1) != 1) return 0x1b;
    switch (seq[1]) {
    case 'A': return GFX_KEY_UP;
    case 'B': return GFX_KEY_DOWN;
    case 'C': return GFX_KEY_RIGHT;
    case 'D': return GFX_KEY_LEFT;
    }
    return 0x1b;
}

void gfx_sleep(int ms)
{
    struct timespec ts = { ms / 1000, (ms % 1000) * 1000000L };
    nanosleep(&ts, NULL);
}

long gfx_ticks(void)
{
    struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
    return (t.tv_sec - t0.tv_sec) * 1000L + (t.tv_nsec - t0.tv_nsec) / 1000000L;
}

int gfx_rand(int n)
{
    rng ^= rng << 13; rng ^= rng >> 7; rng ^= rng << 17;  /* xorshift64 */
    return n > 0 ? (int)(rng % (unsigned long)n) : 0;
}

void gfx_blit(int x, int y, const unsigned char *sprite)
{
    int w = sprite[0], h = sprite[1];
    const unsigned char *p = sprite + 2;
    for (int j = 0; j < h; j++)
        for (int i = 0; i < w; i++, p += 2)
            if (p[0]) gfx_put(x + i, y + j, p[0], p[1]);
}

#define TILE_BYTES (1 + 2 * GFX_TILE_W * GFX_TILE_H)

void gfx_map(int x, int y, const char *map, int w, int h, const unsigned char *tiles)
{
    for (int j = 0; j < h; j++)
        for (int i = 0; i < w; i++) {
            unsigned char c = (unsigned char)map[j * w + i];
            const unsigned char *t = tiles;
            while (t[0] && t[0] != c) t += TILE_BYTES;
            if (!t[0]) t = tiles;               /* inconnu: première tuile */
            const unsigned char *p = t + 1;
            for (int tj = 0; tj < GFX_TILE_H; tj++)
                for (int ti = 0; ti < GFX_TILE_W; ti++, p += 2)
                    gfx_put(x + GFX_TILE_W * i + ti, y + GFX_TILE_H * j + tj, p[0], p[1]);
        }
}
