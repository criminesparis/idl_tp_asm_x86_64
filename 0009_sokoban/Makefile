include ../common.mk

JEU = ../0007_jeu
CFLAGS += -I$(JEU)

all: sokoban

gfx.o: $(JEU)/gfx.c $(JEU)/gfx.h $(JEU)/gfx_consts.h
	$(CC) $(CFLAGS) -O2 -c -o $@ $<

levels.h levels.inc: levels.txt mklevels.py
	python3 mklevels.py levels.txt

sokoban: sokoban.c levels.h gfx.o
	$(CCLD) $(CFLAGS) -o $@ sokoban.c gfx.o

# Votre version: $(ARCH)/sokoban.S
jeu: $(ARCH)/sokoban.S levels.inc gfx.o
	$(CCLD) $(CFLAGS) -o $@ $(ARCH)/sokoban.S gfx.o

run: sokoban
	$(RUN) ./sokoban

# Rejoue les solutions des cinq niveaux fournis, enchaînées par n
SOLUTIONS = LLURnLUUDDRRRUUnLUUULDLDRRRRDRUnUUULDULDnRRRUUULDULLULDDRDL
check: sokoban
	@./sokoban $(SOLUTIONS) | tail -1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g'

clean:
	rm -rf *.o sokoban jeu *.dSYM

.PHONY: all run check clean
