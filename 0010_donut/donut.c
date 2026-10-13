/* Rotating donut on libgfx. Same calculations as aarch64/donut.S. */
#include "gfx.h"
#include <math.h>
#include <string.h>

#define WIDTH 80
#define HEIGHT 22
#define BUF_SIZE (WIDTH * HEIGHT)

int main(void)
{
    float A = 0, B = 0;
    float z[BUF_SIZE];
    char b[BUF_SIZE];
    const char *shades = ".,-~:;=!*#$@";

    if (gfx_open(WIDTH, HEIGHT) < 0) return 1;

    for (;;) {
        memset(b, ' ', sizeof b);
        memset(z, 0, sizeof z);
        float e = sinf(A), g = cosf(A);
        float m = cosf(B), n = sinf(B);

        for (float j = 0; j < 6.28f; j += 0.07f) {
            float d = cosf(j), f = sinf(j), h = d + 2;
            for (float i = 0; i < 6.28f; i += 0.02f) {
                float c = sinf(i), l = cosf(i);
                float D = 1 / (c * h * e + f * g + 5);
                float t = c * h * g - f * e;
                int x = WIDTH / 2 + (l * h * m - t * n) * 30 * D;
                int y = HEIGHT / 2 + (l * h * n + t * m) * 15 * D;
                if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT) continue;

                int o = x + WIDTH * y;
                if (D <= z[o]) continue;
                z[o] = D;
                float N = 8 * ((f * e - c * d * g) * m
                              - c * d * e - f * g - l * d * n);
                int shade = N > 0 ? (int)N : 0;
                if (shade > 11) shade = 11;
                b[o] = shades[shade];
            }
        }

        gfx_clear(GFX_BLACK);
        for (int y = 0; y < HEIGHT; y++)
            for (int x = 0; x < WIDTH; x++)
                if (b[y * WIDTH + x] != ' ')
                    gfx_put(x, y, b[y * WIDTH + x], GFX_CYAN);
        gfx_text(0, 0, "press q to quit", GFX_WHITE);
        gfx_present();

        int key;
        while ((key = gfx_key()) != GFX_KEY_NONE)
            if (key == 'q' || key == 'Q') {
                gfx_close();
                return 0;
            }

        A += 0.04f;
        B += 0.02f;
        gfx_sleep(30);
    }
}
