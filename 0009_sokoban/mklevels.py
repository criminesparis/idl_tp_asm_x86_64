"""Convertit levels.txt en levels.h (C) et levels.inc (assembleur).

Chaque niveau est complété par des espaces pour occuper LEVEL_W x LEVEL_H
cases, de sorte que le niveau n soit à l'adresse levels + n * LEVEL_W * LEVEL_H.
"""
import sys

src = sys.argv[1] if len(sys.argv) > 1 else "levels.txt"
LEVEL_W, LEVEL_H = 20, 12
levels, cur = [], []
for line in open(src):
    line = line.rstrip("\n")
    if line.startswith(";"):
        continue
    if line.strip() == "":
        if cur: levels.append(cur); cur = []
        continue
    cur.append(line)
if cur: levels.append(cur)

for n, lv in enumerate(levels):
    assert len(lv) <= LEVEL_H and max(map(len, lv)) <= LEVEL_W, f"niveau {n + 1} trop grand"
rows = [[r.ljust(LEVEL_W) for r in lv] + [" " * LEVEL_W] * (LEVEL_H - len(lv)) for lv in levels]

with open("levels.h", "w") as f:
    f.write(f"/* Généré par mklevels.py depuis {src}: ne pas éditer. */\n")
    f.write(f"#define LEVEL_W {LEVEL_W}\n#define LEVEL_H {LEVEL_H}\n#define NLEVELS {len(levels)}\n")
    f.write("static const char levels_data[NLEVELS][LEVEL_H][LEVEL_W + 1] = {\n")
    for lv in rows:
        f.write("    {\n" + "".join(f'        "{r}",\n' for r in lv) + "    },\n")
    f.write("};\n")
with open("levels.inc", "w") as f:
    f.write(f"// Généré par mklevels.py depuis {src}: ne pas éditer.\n")
    f.write(f"#define LEVEL_W {LEVEL_W}\n#define LEVEL_H {LEVEL_H}\n#define NLEVELS {len(levels)}\n")
    f.write("levels_data:\n")
    for lv in rows:
        for r in lv:
            f.write(f'    .ascii "{r}"\n')
print(f"{len(levels)} niveaux, {LEVEL_W} x {LEVEL_H}")
