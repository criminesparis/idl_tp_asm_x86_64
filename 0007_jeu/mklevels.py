"""Convertit levels.txt en levels.h (C) et levels.inc (assembleur).

Chaque niveau fait exactement LEVEL_W x LEVEL_H cases; le niveau n commence
à l'adresse levels_data + n * LEVEL_W * LEVEL_H. Les lignes commençant par
; sont des commentaires, une ligne vide (sans aucun caractère) sépare deux
niveaux.
Légende: '#' brique (creusable), '@' béton, 'H' échelle, '-' barre, '$' or,
'S' échelle de sortie (cachée tant qu'il reste de l'or), '&' départ du joueur,
'0' départ d'un ennemi, ' ' vide.
"""
import sys

src = sys.argv[1] if len(sys.argv) > 1 else "levels.txt"
LEVEL_W, LEVEL_H = 28, 16
levels, cur = [], []
for line in open(src):
    line = line.rstrip("\n")
    if line.startswith(";"):
        continue
    if line == "":                  # ligne vide: fin de niveau (une rangée
        if cur: levels.append(cur); cur = []    # de 28 espaces reste une rangée)
        continue
    cur.append(line)
if cur: levels.append(cur)
for n, lv in enumerate(levels):
    assert len(lv) == LEVEL_H and all(len(r) == LEVEL_W for r in lv), \
        f"niveau {n + 1}: attendu {LEVEL_W} x {LEVEL_H}"

with open("levels.h", "w") as f:
    f.write(f"/* Généré par mklevels.py depuis {src}: ne pas éditer. */\n")
    f.write(f"#define LEVEL_W {LEVEL_W}\n#define LEVEL_H {LEVEL_H}\n#define NLEVELS {len(levels)}\n")
    f.write("static const char levels_data[NLEVELS][LEVEL_H][LEVEL_W + 1] = {\n")
    for lv in levels:
        f.write("    {\n" + "".join(f'        "{r}",\n' for r in lv) + "    },\n")
    f.write("};\n")
with open("levels.inc", "w") as f:
    f.write(f"// Généré par mklevels.py depuis {src}: ne pas éditer.\n")
    f.write(f"#define LEVEL_W {LEVEL_W}\n#define LEVEL_H {LEVEL_H}\n#define NLEVELS {len(levels)}\n")
    f.write("levels_data:\n")
    for lv in levels:
        for r in lv:
            f.write(f'    .ascii "{r}"\n')
print(f"{len(levels)} niveaux, {LEVEL_W} x {LEVEL_H}")
