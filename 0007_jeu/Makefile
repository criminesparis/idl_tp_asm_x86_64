include ../common.mk

all: demo_c demo_asm lode

gfx.o: gfx.c gfx.h gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

demo_c: demo.c gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

demo_asm: $(ARCH)/demo.S gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

# Référence en C du Lode Runner
lode: lode.c levels.h gfx.o
	$(CCLD) $(CFLAGS) -o $@ lode.c gfx.o

# Les niveaux, convertis pour le C et pour l'assembleur
levels.h levels.inc: levels.txt mklevels.py
	python3 mklevels.py levels.txt

# Votre jeu: mettez votre source dans $(ARCH)/jeu.S
jeu: $(ARCH)/jeu.S levels.inc gfx.o
	$(CCLD) $(CFLAGS) -o $@ $(ARCH)/jeu.S gfx.o

run: lode
	$(RUN) ./lode

clean:
	rm -rf *.o demo_c demo_asm lode jeu *.dSYM

.PHONY: all run clean
