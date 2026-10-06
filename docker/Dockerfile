# Un Linux prêt pour les TP d'assembleur, dans l'une ou l'autre architecture:
#   docker build -t idl-asm docker/                       # architecture de la machine
#   docker build --platform linux/amd64 -t idl-asm:amd64 docker/
#   docker build --platform linux/arm64 -t idl-asm:arm64 docker/
# Contient gcc, gdb, make, python3, et la chaîne croisée vers l'autre
# architecture avec qemu-user pour exécuter ses binaires (make ARCH=...).
FROM gcc:14
RUN set -e; \
    case "$(uname -m)" in \
      x86_64)  CROSS=aarch64 ;; \
      aarch64) CROSS=x86-64 ;; \
      *) echo "architecture inconnue: $(uname -m)"; exit 1 ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gdb make python3 qemu-user \
      gcc-$CROSS-linux-gnu binutils-$CROSS-linux-gnu; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /w
CMD ["bash"]
