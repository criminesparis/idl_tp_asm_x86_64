include ../../common.mk

PROG = fib_binet

all: $(PROG)

$(PROG): fib_binet.c $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $^

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
