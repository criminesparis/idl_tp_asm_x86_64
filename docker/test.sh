#!/bin/sh
# Test de fumée de tous les exercices, à lancer dans le conteneur idl-asm
# avec le dépôt monté sur /w: construit, exécute, puis nettoie. Avec un
# argument (x86_64 ou aarch64), refait les exemples en compilation croisée
# et les exécute sous qemu. Voir docker/Makefile.
set -u
cd /w
echo "### $(uname -m), $(gcc --version | head -1)"
make -s -C 0001_hello_world_syscall info | sed -n 1p
fail=0
for d in 0001_hello_world_syscall 0002_hello_world_libc 0003_argv 0004_max3 0007_jeu 0008_snake 0009_sokoban; do
  make -C $d clean >/dev/null 2>&1
  if ! make -C $d >/tmp/build.log 2>&1; then echo "$d: ÉCHEC de construction"; tail -5 /tmp/build.log; fail=1; continue; fi
  case $d in
    0001*|0002*) out=$(./$d/hello) ;;
    0003*)       out=$(./$d/argv un deux | tr '\n' ' ') ;;
    0004*)       out=$(./$d/max3 | head -1) ;;
    0007*)       ./$d/lode RRRRRRRRRRRRzLq >/tmp/lode.txt 2>&1; out="lode: $(tail -c 17 /tmp/lode.txt | tr -d '\n')"; printf q | ./$d/demo_asm >/dev/null && out="$out, demo_asm ok" ;;
    0008*)       out=$(./$d/snake RRRDDDLLLUU 2>/dev/null | tail -1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' | grep -o 'Score final.*') ;;
    0009*)       out=$(make -s -C $d check | sed 's/^ *//') ;;
  esac
  echo "$d: $out"
  make -C $d clean >/dev/null 2>&1
done
if [ $# -ge 1 ]; then
  echo "### croisé ARCH=$1, exécution sous qemu-$1"
  for d in 0001_hello_world_syscall 0002_hello_world_libc 0003_argv; do
    if make -C $d ARCH=$1 >/tmp/build.log 2>&1; then
      echo "$d: $(make -s -C $d ARCH=$1 run 2>&1 | head -1)"
    else echo "$d: ÉCHEC de construction croisée"; tail -3 /tmp/build.log; fail=1; fi
    make -C $d clean >/dev/null 2>&1
  done
fi
exit $fail
