#!/bin/bash
# Menu de wofi: lista los repos git bajo ~/projects y abre kitty + zellij --layout dev ahi.

BASE="$HOME/projects"

mapfile -t repos < <(find "$BASE" -maxdepth 4 -mindepth 1 -type d -name .git 2>/dev/null | sed 's|/\.git$||' | sort)

if [ ${#repos[@]} -eq 0 ]; then
    notify-send "Proyectos" "No encontre repos git bajo $BASE"
    exit 0
fi

declare -A path_by_label
choices=""
for repo in "${repos[@]}"; do
    label="${repo#"$BASE"/}"
    path_by_label["$label"]="$repo"
    choices+="$label"$'\n'
done

chosen=$(printf '%s' "$choices" | wofi --dmenu --prompt "Proyecto (zellij dev)")
[ -z "$chosen" ] && exit 0

target="${path_by_label[$chosen]:-}"
[ -z "$target" ] && exit 0

kitty -d "$target" zellij --layout dev
