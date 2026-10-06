# Un Linux prêt pour les TP d'assembleur, dans l'une ou l'autre architecture.
# Construction: make -C docker images (ou image-amd64, image-arm64), qui
# utilise buildx s'il existe, sinon mkimage.sh (voir ce fichier).
# Contient gcc, gdb, make, python3, et la chaîne croisée vers l'autre
# architecture avec qemu-user pour exécuter ses binaires (make ARCH=...).
# Les paquets installés sont les mêmes que dans mkimage.sh: garder les deux
# listes identiques.
FROM gcc:14
RUN set -e; \
    case "$(uname -m)" in \
      x86_64)  GNU=aarch64; DEB=arm64 ;; \
      aarch64) GNU=x86-64;  DEB=amd64 ;; \
      *) echo "architecture inconnue: $(uname -m)"; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gdb make python3 qemu-user \
      gcc-$GNU-linux-gnu binutils-$GNU-linux-gnu libc6-dev-$DEB-cross; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /w
CMD ["bash"]
