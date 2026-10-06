/* Exemple en C de l'usage de libgfx: un bloc que l'on déplace avec les
 * flèches, q pour quitter. L'équivalent en assembleur est dans
 * x86_64/demo.S et aarch64/demo.S. */
#include "gfx.h"

int main(void)
{
    int x = 30, y = 10;
    if (gfx_open(60, 20) < 0) return 1;
    for (;;) {
        gfx_clear(GFX_BLACK);
        gfx_rect(x, y, 2, 1, '#', GFX_GREEN);
        gfx_text(0, 0, "fleches: deplacer, q: quitter", GFX_WHITE);
        gfx_present();
        int k = gfx_key();
        if (k == 'q') break;
        if (k == GFX_KEY_LEFT  && x > 0)  x--;
        if (k == GFX_KEY_RIGHT && x < 58) x++;
        if (k == GFX_KEY_UP    && y > 1)  y--;
        if (k == GFX_KEY_DOWN  && y < 19) y++;
        gfx_sleep(30);
    }
    gfx_close();
    return 0;
}
