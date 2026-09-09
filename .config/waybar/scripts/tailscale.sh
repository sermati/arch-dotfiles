#!/bin/bash
# Waybar custom module: Tailscale status (read-only, no root needed)

if ! command -v tailscale >/dev/null; then
    echo '{"text":"","tooltip":"tailscale no instalado","class":"hidden"}'
    exit 0
fi

json=$(tailscale status --json 2>/dev/null)
state=$(grep -m1 '"BackendState"' <<<"$json" | sed -E 's/.*: *"([^"]+)".*/\1/')

case "$state" in
    Running)
        ip=$(tailscale ip -4 2>/dev/null)
        peers=$(tailscale status 2>/dev/null | grep -c '^100\.')
        tooltip="Tailscale conectado\nIP: ${ip}\nPeers visibles: ${peers}\n\nClick: ver estado completo\nClick derecho: abrir admin console"
        echo "{\"text\":\"\",\"tooltip\":\"${tooltip}\",\"class\":\"connected\"}"
        ;;
    Stopped)
        echo '{"text":"","tooltip":"Tailscale detenido","class":"disconnected"}'
        ;;
    NeedsLogin)
        echo '{"text":"","tooltip":"Tailscale: falta iniciar sesion","class":"disconnected"}'
        ;;
    *)
        echo "{\"text\":\"\",\"tooltip\":\"Tailscale: estado desconocido (${state})\",\"class\":\"disconnected\"}"
        ;;
esac
