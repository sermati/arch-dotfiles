#!/bin/bash
# Waybar custom module: rbw (Bitwarden CLI) lock status

if ! command -v rbw >/dev/null; then
    echo '{"text":"","tooltip":"rbw no instalado","class":"hidden"}'
    exit 0
fi

if rbw unlocked >/dev/null 2>&1; then
    echo '{"text":"","tooltip":"rbw: vault desbloqueado\n\nClick derecho: bloquear","class":"unlocked"}'
else
    echo '{"text":"","tooltip":"rbw: vault bloqueado\n\nClick: desbloquear","class":"locked"}'
fi
