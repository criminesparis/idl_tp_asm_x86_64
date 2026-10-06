# Un Linux de chaque architecture, avec Docker

Pour faire les exercices sur l'autre architecture que celle de votre
machine, ou pour avoir un Linux sous macOS, sans rien installer d'autre que
Docker (Docker Desktop, ou Colima sous macOS).

L'image contient gcc, gdb, make, python3, et la chaîne croisée vers l'autre
architecture avec qemu-user, donc `make ARCH=...` y fonctionne dans les
deux sens.

```bash
make -C docker shell-arm64     # un shell Linux AArch64, le dépôt monté sur /w
make -C docker shell-amd64     # un shell Linux x86-64
```

Dans le shell, `cd 0001_hello_world_syscall && make run`. Les fichiers
modifiés dans le conteneur sont ceux de votre dépôt. Pour déboguer dans le
conteneur, ajoutez `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined`
à la commande `docker run` du Makefile, sinon `gdb` ne peut pas s'attacher.

Sur un Mac Apple Silicon, l'image amd64 tourne en émulation, environ dix
fois plus lentement; sur un PC, c'est l'image arm64. Docker Desktop active
cette émulation tout seul; avec Colima, démarrez-le avec
`colima start --vm-type vz --vz-rosetta` pour une émulation rapide.

La construction de l'image de l'autre architecture demande `buildx`, présent
dans Docker Desktop. Sans lui (Colima sans le plugin), le Makefile passe par
`mkimage.sh`, qui installe les paquets dans un conteneur de la bonne
architecture et le fige avec `docker commit`.

## Test de fumée

`make -C docker test` construit les deux images, puis compile, exécute et
nettoie tous les exercices dans chacune, y compris en compilation croisée.
C'est ce que l'enseignant lance avant de publier une modification.

Dans l'image émulée, le compilateur croisé tourne lui-même en émulation: il
lui arrive de planter une fois sur dix avec une erreur interne. Relancer
suffit; les binaires produits ne sont pas en cause.
