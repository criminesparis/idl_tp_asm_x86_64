include ../common.mk

PROG = gcd

all: $(PROG)

$(PROG): $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $<

run: $(PROG)
	$(RUN) ./$(PROG) 6 3

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
