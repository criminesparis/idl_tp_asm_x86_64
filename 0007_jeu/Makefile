include ../common.mk

all: demo_c demo_asm lode

gfx.o: gfx.c gfx.h gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

demo_c: demo.c gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

demo_asm: $(ARCH)/demo.S gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

# Référence en C du Lode Runner
lode: lode.c level1.h gfx.o
	$(CCLD) $(CFLAGS) -o $@ lode.c gfx.o

# Le niveau, converti pour le C et pour l'assembleur
level1.h level1.inc: level1.txt mklevel.py
	python3 mklevel.py level1.txt

# Votre jeu: mettez votre source dans $(ARCH)/jeu.S
jeu: $(ARCH)/jeu.S level1.inc gfx.o
	$(CCLD) $(CFLAGS) -o $@ $(ARCH)/jeu.S gfx.o

run: lode
	$(RUN) ./lode

clean:
	rm -rf *.o demo_c demo_asm lode jeu *.dSYM

.PHONY: all run clean
