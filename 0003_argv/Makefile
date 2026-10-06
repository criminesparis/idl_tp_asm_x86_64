include ../common.mk

PROG = argv

all: $(PROG)

$(PROG): $(ARCH)/$(PROG).S
	$(CCLD) $(CFLAGS) -o $@ $<

run: $(PROG)
	$(RUN) ./$(PROG) un deux trois

clean:
	rm -rf *.o $(PROG) *.dSYM

.PHONY: all run clean
