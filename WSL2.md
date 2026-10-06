# Petit guide WSL2 pour les TP

Sous Windows, les TP se font dans une distribution Linux installée avec
WSL2 (*Windows Subsystem for Linux*, version 2). Vous obtenez un vrai
noyau Linux, `gcc`, `gdb` et les mêmes commandes que vos camarades sous
Linux ou macOS. Comptez 15 minutes et un redémarrage.

## 1. Installer WSL2 et Ubuntu

Dans un terminal Windows (PowerShell) **ouvert en administrateur**:

```powershell
wsl --install
```

Cette commande active WSL2, télécharge Ubuntu et demande un redémarrage.
Au premier lancement d'Ubuntu (menu Démarrer, "Ubuntu"), choisissez un nom
d'utilisateur et un mot de passe: c'est votre compte Linux.

Si WSL était déjà installé, vérifiez que vous êtes bien en version 2:

```powershell
wsl --list --verbose     # la colonne VERSION doit indiquer 2
wsl --set-default-version 2
wsl --update
```

## 2. Installer les outils

Dans le terminal Ubuntu:

```bash
sudo apt update
sudo apt install -y build-essential gdb git make vim
```

Pour la variante AArch64 des exercices (compilation croisée et émulation),
ajoutez:

```bash
sudo apt install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user
```

Vérification:

```bash
gcc --version
gdb --version
aarch64-linux-gnu-gcc --version
```

## 3. Où mettre vos fichiers

Travaillez dans votre répertoire Linux (`/home/<vous>`), pas dans
`/mnt/c/...`: le système de fichiers Windows est beaucoup plus lent depuis
WSL et les permissions y sont approximatives.

```bash
cd ~
git clone <url du dépôt>
cd idl_tp_asm_x86_64
make -C 0001_hello_world_syscall run
```

Depuis Windows, vos fichiers Linux sont visibles dans l'Explorateur à
l'adresse `\\wsl$\Ubuntu\home\<vous>`.

## 4. Éditer avec VS Code

Installez VS Code sous Windows, puis l'extension **WSL** (Microsoft). Depuis
le terminal Ubuntu, `code .` ouvre le répertoire courant dans VS Code, avec
le terminal intégré et le débogueur qui tournent dans Linux.

## 5. Problèmes fréquents

- **`wsl --install` ne fait rien ou échoue.** Vérifiez que la
  virtualisation est activée dans le BIOS/UEFI (Intel VT-x ou AMD-V) et que
  Windows est à jour (Windows 10 version 2004 ou plus, ou Windows 11).
- **Pas de réseau dans Ubuntu.** Souvent un antivirus ou un VPN. Essayez
  `wsl --shutdown` dans PowerShell puis relancez Ubuntu.
- **`make` dit `command not found`.** Le paquet `build-essential` n'est pas
  installé, reprenez l'étape 2.
- **Le clavier n'est pas en AZERTY dans le terminal.** C'est un réglage du
  terminal Windows, pas de Linux: utilisez l'application *Windows Terminal*
  qui respecte la disposition du clavier.
- **L'horloge d'Ubuntu est fausse après une mise en veille.** `sudo hwclock
  -s` ou `wsl --shutdown`.

## 6. Ce que WSL2 ne fait pas

- Pas d'accès direct au matériel: les TP STM32 passent par les outils ST
  sous Windows, pas par WSL.
- `perf` et les compteurs matériels sont limités: pour les TP de mesure du
  chapitre 2, les résultats seront moins précis que sous Linux natif.
