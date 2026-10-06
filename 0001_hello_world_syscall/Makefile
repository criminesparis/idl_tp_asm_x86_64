include ../common.mk

PROG = hello

all: $(PROG)

$(PROG): $(PROG).o
	$(LD) -o $@ $<

$(PROG).o: $(ARCH)/$(PROG).S
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(PROG)
	$(RUN) ./$(PROG)

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
