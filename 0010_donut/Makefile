include ../common.mk

CFLAGS += -I.
LDLIBS += -lm

all: donut_c donut_asm

gfx.o: gfx.c gfx.h gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

donut_c: donut.c gfx.o
	$(CCLD) $(CFLAGS) -o $@ $^ $(LDLIBS)

donut_asm: $(ARCH)/donut.S gfx.o gfx_consts.h
	$(CCLD) $(CFLAGS) -o $@ $(ARCH)/donut.S gfx.o $(LDLIBS)

run: donut_asm
	$(RUN) ./donut_asm

clean:
	rm -rf *.o donut_c donut_asm donut jeu *.dSYM

.PHONY: all run clean
