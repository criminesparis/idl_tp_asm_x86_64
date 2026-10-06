#!/bin/sh
# Construit l'image idl-asm pour une plateforme SANS buildx: le constructeur
# d'images classique de Docker ignore --platform, on lance donc un conteneur
# de la bonne architecture, on y installe les paquets et on le fige avec
# docker commit. Mêmes paquets que dans le Dockerfile.
# Usage: sh mkimage.sh linux/amd64 idl-asm:amd64
set -e
PLATFORM=$1; TAG=$2
docker rm -f idl-asm-build >/dev/null 2>&1 || true
docker run --platform "$PLATFORM" --name idl-asm-build gcc:14 sh -c '
  set -e
  case "$(uname -m)" in
    x86_64)  GNU=aarch64; DEB=arm64 ;;
    aarch64) GNU=x86-64;  DEB=amd64 ;;
    *) echo "architecture inconnue: $(uname -m)"; exit 1 ;;
  esac
  apt-get update
  apt-get install -y --no-install-recommends gdb make python3 qemu-user \
    gcc-$GNU-linux-gnu binutils-$GNU-linux-gnu libc6-dev-$DEB-cross
  rm -rf /var/lib/apt/lists/*'
docker commit --change 'WORKDIR /w' --change 'CMD ["bash"]' idl-asm-build "$TAG" >/dev/null
docker rm idl-asm-build >/dev/null
echo "image $TAG construite ($PLATFORM)"
