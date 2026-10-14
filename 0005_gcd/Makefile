include ../common.mk

PROG = gcd

all: $(PROG)

$(PROG): callgcd.c $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $^

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
