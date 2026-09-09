#!/bin/bash
# Waybar image module: Tailscale logo, coloreado segun estado. Salida: $path\n$tooltip

ICONS=~/.config/waybar/icons

if ! command -v tailscale >/dev/null; then
    echo "${ICONS}/tailscale-error.svg"
    echo "tailscale no instalado"
    exit 0
fi

json=$(tailscale status --json 2>/dev/null)
state=$(grep -m1 '"BackendState"' <<<"$json" | sed -E 's/.*: *"([^"]+)".*/\1/')

case "$state" in
    Running)
        ip=$(tailscale ip -4 2>/dev/null)
        peers=$(tailscale status 2>/dev/null | grep -c '^100\.')
        echo "${ICONS}/tailscale-connected.svg"
        printf 'Tailscale conectado\nIP: %s\nPeers visibles: %s\n\nClick: ver estado completo\nClick medio: abrir admin console' "$ip" "$peers"
        ;;
    Stopped)
        echo "${ICONS}/tailscale-disconnected.svg"
        echo "Tailscale detenido"
        ;;
    NeedsLogin)
        echo "${ICONS}/tailscale-disconnected.svg"
        echo "Tailscale: falta iniciar sesion"
        ;;
    *)
        echo "${ICONS}/tailscale-error.svg"
        printf 'Tailscale: estado desconocido (%s)' "$state"
        ;;
esac
