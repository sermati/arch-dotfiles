#!/bin/bash
# Bootstrap de dotfiles (repo git "bare" apuntando a $HOME).
#
# Uso en una maquina nueva o recien formateada:
#   curl -fsSL <RAW_URL_DE_ESTE_ARCHIVO> | bash
#
# Es idempotente: si $HOME/.dotfiles ya existe, hace pull en vez de clonar.
set -euo pipefail

REPO_URL="__DOTFILES_REPO_URL__"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

if [ -d "$DOTFILES_DIR" ]; then
    echo "==> $DOTFILES_DIR ya existe, actualizando (pull)..."
    dotfiles pull
else
    echo "==> clonando dotfiles (bare) en $DOTFILES_DIR..."
    git clone --bare "$REPO_URL" "$DOTFILES_DIR"
fi

dotfiles config status.showUntrackedFiles no

echo "==> intentando checkout..."
checkout_output=$(dotfiles checkout 2>&1) && checkout_ok=1 || checkout_ok=0

if [ "$checkout_ok" -eq 0 ]; then
    echo "==> hay archivos existentes que chocan, los muevo a $BACKUP_DIR"
    conflicts=$(echo "$checkout_output" | sed -n 's/^\t//p')

    if [ -z "$conflicts" ]; then
        echo "No pude parsear los archivos en conflicto. Salida de git:"
        echo "$checkout_output"
        exit 1
    fi

    mkdir -p "$BACKUP_DIR"
    echo "$conflicts" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        mv "$HOME/$file" "$BACKUP_DIR/$file"
        echo "   movido: $file"
    done

    dotfiles checkout
fi

dotfiles submodule update --init --recursive 2>/dev/null || true

echo
echo "==> listo."
if [ -d "$BACKUP_DIR" ]; then
    echo "==> backup de archivos previos en: $BACKUP_DIR"
fi
echo "==> abri una terminal nueva (o 'source ~/.bashrc') para tener el alias 'dotfiles' disponible."
