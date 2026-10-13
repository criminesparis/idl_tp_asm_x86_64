include ../common.mk

PROG = gcd

all: $(PROG)

$(PROG): callmax3.c $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $^

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
