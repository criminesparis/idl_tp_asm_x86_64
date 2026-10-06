# Construit les images et lance le test de fumée dans les deux architectures.
#   make -C docker test          # les deux
#   make -C docker test-arm64    # une seule
# Sur un Mac Apple Silicon, l'image amd64 tourne en émulation (lente).
ROOT := $(abspath ..)

images: image-amd64 image-arm64

# Avec buildx (Docker Desktop), docker build respecte --platform. Sans
# (Colima sans le plugin), mkimage.sh fait le même travail par run + commit.
HAVE_BUILDX := $(shell docker buildx version >/dev/null 2>&1 && echo yes)

image-amd64:
ifeq ($(HAVE_BUILDX),yes)
	docker buildx build --platform linux/amd64 --load -t idl-asm:amd64 .
else
	sh mkimage.sh linux/amd64 idl-asm:amd64
endif

image-arm64:
ifeq ($(HAVE_BUILDX),yes)
	docker buildx build --platform linux/arm64 --load -t idl-asm:arm64 .
else
	sh mkimage.sh linux/arm64 idl-asm:arm64
endif

# Les deux tests, même si le premier échoue; le code de retour reflète les deux.
test:
	@rc=0; $(MAKE) test-amd64 || rc=1; $(MAKE) test-arm64 || rc=1; exit $$rc

test-amd64: image-amd64
	docker run --rm --platform linux/amd64 -v "$(ROOT)":/w idl-asm:amd64 sh docker/test.sh aarch64

test-arm64: image-arm64
	docker run --rm --platform linux/arm64 -v "$(ROOT)":/w idl-asm:arm64 sh docker/test.sh x86_64

# Un shell dans l'image de l'architecture voulue, le dépôt monté sur /w
shell-amd64: image-amd64
	docker run --rm -it --platform linux/amd64 -v "$(ROOT)":/w idl-asm:amd64

shell-arm64: image-arm64
	docker run --rm -it --platform linux/arm64 -v "$(ROOT)":/w idl-asm:arm64

.PHONY: images image-amd64 image-arm64 test test-amd64 test-arm64 shell-amd64 shell-arm64
