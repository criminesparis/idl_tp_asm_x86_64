include ../common.mk

PROG = fib

ASM_SOURCES = \
    $(ARCH)/fib_recursive.S \
    $(ARCH)/fib_iterative.S \
    $(ARCH)/fib_binet.S

all: $(PROG)

$(PROG): fib.c $(ASM_SOURCES)
	$(CCLD) $(CFLAGS) -o $@ $^

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf $(PROG) *.o *.dSYM

.PHONY: all run clean