#!/bin/bash
# Menu de wofi para cambiar que hace systemd-logind al cerrar la tapa.
# Se invoca desde el item "Tapa / Energia" del menu principal (SUPER+SPACE).

current=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
    org.freedesktop.login1.Manager HandleLidSwitch 2>/dev/null | cut -d'"' -f2)

declare -A labels=(
    [suspend]="Suspender"
    [lock]="Bloquear pantalla"
    [ignore]="Ignorar"
)

options=""
for key in suspend lock ignore; do
    label="${labels[$key]}"
    [ "$key" = "$current" ] && label="$label (actual)"
    options+="$label"$'\n'
done

chosen=$(printf '%s' "$options" | wofi --dmenu --prompt "Tapa: comportamiento al cerrar")

case "$chosen" in
    "Suspender"*)         value=suspend ;;
    "Bloquear pantalla"*) value=lock ;;
    "Ignorar"*)           value=ignore ;;
    *) exit 0 ;;
esac

if pkexec bash -c "
    sed -i 's/^#\?HandleLidSwitch=.*/HandleLidSwitch=$value/' /etc/systemd/logind.conf
    grep -q '^HandleLidSwitch=' /etc/systemd/logind.conf || echo 'HandleLidSwitch=$value' >> /etc/systemd/logind.conf
    systemctl reload systemd-logind
"; then
    notify-send "Tapa" "Comportamiento al cerrar: ${labels[$value]}"
else
    notify-send -u critical "Tapa" "No se pudo aplicar el cambio"
fi
