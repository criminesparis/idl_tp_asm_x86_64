# Snake

Exercice d'échauffement avant le projet: le Snake, en assembleur, sur
libgfx (voir [`../0007_jeu/README.md`](../0007_jeu/README.md) pour l'API).
`snake.c` est la référence en C: lisez-la, puis traduisez-la fonction par
fonction dans `x86_64/snake.S` ou `aarch64/snake.S` (`make jeu`).

Ce que cet exercice fait travailler, et qui resservira dans le projet:

1. **Une file circulaire en mémoire.** Le corps du serpent est une suite
   de cases; à chaque pas la tête entre à un bout et la queue sort de
   l'autre. Deux tableaux `bx` et `by` de `W*H` entiers, deux indices
   `head` et `tail`, et le modulo. Grandir, c'est ne pas faire sortir la
   queue.
2. **Une boucle de jeu à pas fixe qui accélère**: la durée du pas est une
   variable, pas une constante.
3. **Le parcours de la file** pour la collision avec le corps et pour le
   dessin: la même boucle, deux usages, donc une fonction qui prend un
   pointeur de fonction, ou deux boucles. Les deux sont acceptés;
   expliquez votre choix.
4. **L'ordre des opérations**: la queue avance avant le test de collision,
   sinon le serpent ne peut jamais suivre sa propre queue. Reproduisez cet
   ordre, puis cassez-le pour voir la différence.

Étapes conseillées: un serpent de longueur 1 qui avance et tourne; les
murs; la pomme et la croissance; la collision avec le corps; le score et
l'accélération.

## Tester

`./snake` joue au clavier. `./snake "RRRDDD.LL"` rejoue une touche par pas
(`.` = aucune touche) puis s'arrête: pratique pour vérifier une règle sans
jouer. La pomme étant tirée au hasard, deux programmes ne font pas la même
partie sur le même script; `make snake_fixed` compile une version où la
pomme suit une suite fixe, à reproduire dans votre assembleur pour comparer
les sorties octet par octet, comme `make check` le fait pour le Lode Runner.
