"""Convertit un niveau ASCII (level1.txt) en level1.h (C) et level1.inc (asm).

Usage: python3 mklevel.py level1.txt
Chaque ligne du fichier est une rangée; toutes doivent avoir la même largeur.
Légende: '#' brique (creusable), '@' béton, 'H' échelle, '-' barre, '$' or,
'S' échelle de sortie (cachée tant qu'il reste de l'or), '&' départ du joueur,
'0' départ d'un ennemi, ' ' vide.
"""
import sys
import os

src = sys.argv[1]
rows = [l.rstrip("\n") for l in open(src)]
w = len(rows[0]); h = len(rows)
assert all(len(r) == w for r in rows), "toutes les lignes doivent avoir la même largeur"
base = os.path.splitext(src)[0]

with open(base + ".h", "w") as f:
    f.write(f"/* Généré par mklevel.py depuis {src}: ne pas éditer. */\n")
    f.write(f"#define LEVEL_W {w}\n#define LEVEL_H {h}\n")
    f.write("static const char level_data[LEVEL_H][LEVEL_W + 1] = {\n")
    for r in rows:
        f.write('    "' + r.replace("\\", "\\\\").replace('"', '\\"') + '",\n')
    f.write("};\n")

with open(base + ".inc", "w") as f:
    f.write(f"// Généré par mklevel.py depuis {src}: ne pas éditer.\n")
    f.write(f"#define LEVEL_W {w}\n#define LEVEL_H {h}\n")
    f.write("level_data:\n")
    for r in rows:
        f.write('    .ascii "' + r.replace("\\", "\\\\").replace('"', '\\"') + '"\n')
print(f"{base}.h et {base}.inc: {w} x {h}")
