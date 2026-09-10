#!/bin/bash
# Menu de wofi para elegir el exit-node de Tailscale.
# tailscale set necesita root: pkexec, salvo que corras una vez
# "sudo tailscale set --operator=$USER" para volverlo passwordless.

json=$(tailscale status --json 2>/dev/null)

nodes=$(printf '%s' "$json" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for peer in d.get('Peer', {}).values():
    if peer.get('ExitNodeOption'):
        print(peer.get('HostName', ''))
")

if [ -z "$nodes" ]; then
    notify-send "Tailscale" "Ningun nodo de tu tailnet esta anunciado como exit-node todavia.

En la maquina que quieras usar como salida: tailscale up --advertise-exit-node (y aprobarlo en la admin console)."
    exit 0
fi

current=$(printf '%s' "$json" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for peer in d.get('Peer', {}).values():
    if peer.get('ExitNode'):
        print(peer.get('HostName', ''))
")

options="Ninguno"$'\n'"$nodes"
chosen=$(printf '%s\n' "$options" | while IFS= read -r n; do
    if [ "$n" = "$current" ] || { [ "$n" = "Ninguno" ] && [ -z "$current" ]; }; then
        echo "$n (actual)"
    else
        echo "$n"
    fi
done | wofi --dmenu --prompt "Tailscale: exit node")

chosen="${chosen% (actual)}"
[ -z "$chosen" ] && exit 0

if [ "$chosen" = "Ninguno" ]; then
    pkexec tailscale set --exit-node=
else
    pkexec tailscale set --exit-node="$chosen"
fi

if [ $? -eq 0 ]; then
    notify-send "Tailscale" "Exit node: $chosen"
else
    notify-send -u critical "Tailscale" "No se pudo cambiar el exit node"
fi
