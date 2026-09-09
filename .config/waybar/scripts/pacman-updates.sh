#!/bin/bash
# Waybar custom module: pending pacman updates (needs pacman-contrib's checkupdates)

if ! command -v checkupdates >/dev/null; then
    echo '{"text":"","tooltip":"instala pacman-contrib para ver actualizaciones","class":"hidden"}'
    exit 0
fi

count=$(checkupdates 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]; then
    echo '{"text":" 0","tooltip":"Sistema actualizado","class":"none"}'
else
    list=$(checkupdates 2>/dev/null | sed 's/^/ /' | head -20 | awk '{printf (NR==1?"%s":"\\n%s"), $0}')
    tooltip="${count} actualizaciones pendientes\\n\\n${list}"
    echo "{\"text\":\" ${count}\",\"tooltip\":\"${tooltip}\",\"class\":\"pending\"}"
fi
