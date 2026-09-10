#!/bin/bash
# Menu de wofi: energia. Poweroff/reboot/suspend son passwordless para la
# sesion activa (polkit "implicit active: yes"), no hace falta pkexec.

order=("Suspender" "Bloquear" "Cerrar sesion" "Reiniciar" "Apagar")

chosen=$(printf '%s\n' "${order[@]}" | wofi --dmenu --prompt "Energia")
[ -z "$chosen" ] && exit 0

confirm() {
    [ "$(printf 'No\nSi' | wofi --dmenu --prompt "Confirmar: $chosen?")" = "Si" ]
}

case "$chosen" in
    "Suspender")     systemctl suspend ;;
    "Bloquear")      hyprlock ;;
    "Cerrar sesion") hyprctl dispatch exit ;;
    "Reiniciar")     confirm && systemctl reboot ;;
    "Apagar")        confirm && systemctl poweroff ;;
esac
