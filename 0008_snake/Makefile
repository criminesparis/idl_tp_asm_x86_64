include ../common.mk

JEU = ../0007_jeu
CFLAGS += -I$(JEU)

all: snake

gfx.o: $(JEU)/gfx.c $(JEU)/gfx.h $(JEU)/gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

snake: snake.c gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

# Version avec pomme déterministe, pour comparer à votre assembleur
snake_fixed: snake.c gfx.o
	$(CCLD) $(CFLAGS) -DFIXED_APPLE -o $@ $^

# Votre version: $(ARCH)/snake.S
jeu: $(ARCH)/snake.S gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

run: snake
	$(RUN) ./snake

clean:
	rm -rf *.o snake snake_fixed jeu *.dSYM

.PHONY: all run clean
