include ../common.mk

PROG = gcd
ASM = $(ARCH)/gcd.S

all: $(PROG)

$(PROG): gcd.c $(ASM)
	$(CCLD) $(CFLAGS) -o $@ $^
ARGS ?= 50 30
run: $(PROG)
	$(RUN) ./$(PROG) $(ARGS)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
