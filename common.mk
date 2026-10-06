# Détection de la machine et choix de la chaîne d'outils.
# À inclure depuis le Makefile de chaque exercice: include ../common.mk
#
# Variables produites:
#   ARCH   x86_64 ou aarch64 (ISA cible; surchargeable: make ARCH=x86_64)
#   OS     Linux ou Darwin (macOS)
#   CC     compilateur, sert aussi à assembler les .S (préprocesseur C)
#   LD     éditeur de liens pour un programme SANS libc (point d'entrée _start)
#   CCLD   éditeur de liens pour un programme AVEC libc (point d'entrée main)
#   RUN    préfixe pour exécuter le binaire (vide, ou qemu-<arch> en émulation)

OS     := $(shell uname -s)
HOST_M := $(shell uname -m)

# Normalisation du nom de l'ISA de la machine hôte.
ifeq ($(HOST_M),x86_64)
  HOST_ARCH := x86_64
else ifneq (,$(filter $(HOST_M),arm64 aarch64))
  HOST_ARCH := aarch64
else
  $(error ISA non prise en charge: $(HOST_M))
endif

# ISA cible: celle de l'hôte par défaut.
ARCH ?= $(HOST_ARCH)
ifeq (,$(filter $(ARCH),x86_64 aarch64))
  $(error ARCH doit valoir x86_64 ou aarch64, pas "$(ARCH)")
endif

ifeq ($(OS),Darwin)
  # macOS: clang sait produire les deux ISA; Rosetta exécute les binaires
  # x86_64 sur Apple Silicon. Le nom Apple de l'ISA AArch64 est arm64.
  CLANG_ARCH := $(if $(filter $(ARCH),aarch64),arm64,x86_64)
  SDK   := $(shell xcrun --show-sdk-path)
  CC    := clang -arch $(CLANG_ARCH)
  LD    := ld -arch $(CLANG_ARCH) -syslibroot $(SDK) -lSystem -e _start
  CCLD  := $(CC)
  RUN   :=
else ifeq ($(OS),Linux)
  ifeq ($(ARCH),$(HOST_ARCH))
    CC   := gcc
    LD   := ld
    CCLD := gcc -no-pie
    RUN  :=
  else
    # Compilation croisée + émulation en mode utilisateur.
    # Debian/Ubuntu: apt install gcc-$(ARCH)-linux-gnu qemu-user
    CC   := $(ARCH)-linux-gnu-gcc
    LD   := $(ARCH)-linux-gnu-ld
    CCLD := $(CC) -no-pie -static
    RUN  := qemu-$(ARCH)
  endif
else
  $(error Système non pris en charge: $(OS). Sous Windows, utiliser WSL2, voir WSL2.md)
endif

CFLAGS ?= -g -Wall

# La cible par défaut reste celle du Makefile de l'exercice, pas "info".
.DEFAULT_GOAL := all

# Affiche la configuration détectée: make info
.PHONY: info
info:
	@echo "OS=$(OS) HOST_ARCH=$(HOST_ARCH) ARCH=$(ARCH)"
	@echo "CC=$(CC)"
	@echo "LD=$(LD)"
	@echo "CCLD=$(CCLD)"
	@echo "RUN=$(RUN)"
