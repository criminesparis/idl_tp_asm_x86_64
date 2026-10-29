include ../common.mk

PROG = fib_binet
ASM = $(ARCH)/fib_binet.S

all: $(PROG)

$(PROG): fib_binet.c $(ASM)
	$(CCLD) $(CFLAGS) -o $@ $^
ARGS ?= 5
run: $(PROG)
	$(RUN) ./$(PROG) $(ARGS)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
