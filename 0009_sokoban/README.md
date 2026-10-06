# Sokoban

Un jeu de règles pures sur une grille, sans temps réel: pousser les
caisses sur les cibles. `sokoban.c` est la référence en C sur libgfx
(voir [`../0007_jeu/README.md`](../0007_jeu/README.md) pour l'API); à
traduire en assembleur dans `x86_64/sokoban.S` ou `aarch64/sokoban.S`
(`make jeu`).

## Les niveaux

`levels.txt` est au format habituel des collections de Sokoban: `#` mur,
`@` joueur, `$` caisse, `.` cible, `*` caisse sur cible, `+` joueur sur
cible, espace sol; une ligne vide sépare les niveaux. `mklevels.py` les
complète à 20 x 12 cases et les écrit dans `levels.h` pour le C et
`levels.inc` pour l'assembleur: le niveau `n` commence à l'adresse
`levels_data + n * LEVEL_W * LEVEL_H`.

Les cinq niveaux fournis sont petits et faits pour les tests; des milliers
de niveaux libres existent au même format, par exemple la collection
Microban de David W. Skinner, qu'il suffit de coller dans `levels.txt`.

## Ce que l'exercice fait travailler

1. **Deux grilles**: le décor (murs, sol, cibles), qui ne change pas, et
   la position des caisses, qui change. Les séparer évite de perdre les
   cibles quand une caisse les quitte.
2. **La règle "deux cases devant"**: pour pousser, il faut regarder la case
   visée et celle d'après. Une seule fonction `move(dx, dy)` sert aux
   quatre directions: c'est le passage de paramètres qui évite quatre
   copies du code.
3. **Une pile de coups** pour annuler: chaque coup empile sa direction et
   si une caisse a été poussée; annuler dépile et refait tout à l'envers.
   Trois octets par entrée: pensez à l'alignement et à l'adressage.
4. **Le test de victoire**, un parcours des deux grilles.
5. **Une boucle sans horloge**: rien ne bouge tant qu'on n'appuie pas,
   donc `gfx_key` est appelé en boucle avec une petite attente.

Étapes conseillées: charger et dessiner un niveau; se déplacer sans
caisses; pousser; détecter la victoire et passer au niveau suivant;
annuler; recommencer.

## Tester

`./sokoban` joue au clavier: flèches, `u` annuler, `r` recommencer, `n`
niveau suivant une fois gagné, `q` quitter. En mode script,
`./sokoban LLURu` rejoue une touche par pas puis quitte, et le programme
indique en sortie si le niveau est résolu. `make check` rejoue les
solutions des cinq niveaux enchaînées; faites de même avec votre version:
les sorties doivent être identiques à celles de `sokoban.c`.
