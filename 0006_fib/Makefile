include ../common.mk

PROG = fib

all: $(PROG)

$(PROG): fib.c $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $^

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
