include ../common.mk

CFLAGS += -I.

all: snake_c snake_asm

gfx.o: gfx.c gfx.h gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

snake_c: snake.c gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^

snake_fixed: snake.c gfx.o
	$(CCLD) $(CFLAGS) -DFIXED_APPLE -o $@ $^

snake_asm: $(ARCH)/snake.S gfx.o gfx_consts.h
	$(CCLD) $(CFLAGS) -o $@ $(ARCH)/snake.S gfx.o

run: snake_asm
	$(RUN) ./snake_asm

clean:
	rm -rf *.o snake_c snake_asm snake_fixed snake jeu *.dSYM

.PHONY: all run clean
