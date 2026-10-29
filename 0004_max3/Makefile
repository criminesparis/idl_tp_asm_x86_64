include ../common.mk

PROG = max3_alt
ASM = $(ARCH)/max3.S

all: $(PROG)

$(PROG): callmax3_alt.c $(ASM)
	$(CCLD) $(CFLAGS) -o $@ $^
ARGS ?= 1 2 3
run: $(PROG)
	$(RUN) ./$(PROG) $(ARGS)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
