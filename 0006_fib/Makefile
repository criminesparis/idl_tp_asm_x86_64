include ../common.mk

PROG = fib

all: $(PROG)

$(PROG): $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $< -lm

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
