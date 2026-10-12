include ../common.mk

PROG = fib

all: $(PROG)

$(PROG): $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $<

run: $(PROG)
	$(RUN) ./$(PROG) 10

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
