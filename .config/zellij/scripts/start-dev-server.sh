#!/bin/bash
# Corre el dev server del proyecto actual:
#  - activa la version de Node correcta (.nvmrc, o si no existe, "engines.node" de package.json)
#    instalandola con nvm si todavia no esta descargada
#  - detecta el package manager por el lockfile (o "packageManager" en package.json) y usa ese

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# --- version de Node ---
if [ -f .nvmrc ]; then
    echo "==> .nvmrc: $(cat .nvmrc)"
    nvm use 2>/dev/null || nvm install
elif [ -f package.json ]; then
    wanted=$(node -p "require('./package.json').engines?.node" 2>/dev/null)
    if [ -n "$wanted" ] && [ "$wanted" != "undefined" ]; then
        echo "==> engines.node: $wanted"
        nvm use "$wanted" 2>/dev/null || nvm install "$wanted"
    fi
fi

# --- package manager ---
if [ -f pnpm-lock.yaml ]; then
    pm=pnpm
elif [ -f yarn.lock ]; then
    pm=yarn
elif [ -f bun.lockb ]; then
    pm=bun
elif [ -f package.json ] && grep -q '"packageManager"' package.json; then
    pm=$(node -p "require('./package.json').packageManager.split('@')[0]" 2>/dev/null)
else
    pm=npm
fi
echo "==> package manager: $pm"

if ! command -v "$pm" >/dev/null 2>&1; then
    if command -v corepack >/dev/null 2>&1; then
        echo "==> $pm no esta instalado, habilitando via corepack..."
        corepack enable
        corepack prepare "$pm"@latest --activate
    else
        echo "==> $pm no esta instalado y no hay corepack disponible. Instalalo a mano."
        exec bash
    fi
fi

if [ -f package.json ] && grep -q '"dev"[[:space:]]*:' package.json; then
    echo "==> corriendo: $pm run dev"
    "$pm" run dev
else
    echo "No encontre un script 'dev' en package.json."
    echo "Quedate en esta shell y arrancalo vos a mano."
    exec bash
fi
