#!/usr/bin/env bash
# Apply screen/keyboard brightness by time of day.
# Day  (07:00–17:59): screen 80%, keyboard 0%
# Night (18:00–06:59): screen 50%, keyboard 33%

set -euo pipefail

KBD_DEVICE="asus::kbd_backlight"
hour=$((10#$(date +%H)))

if (( hour >= 7 && hour < 18 )); then
  mode="day"
  screen_pct=80
  kbd_pct=0
else
  mode="night"
  screen_pct=50
  kbd_pct=33
fi

brightnessctl set "${screen_pct}%" >/dev/null

if brightnessctl -l 2>/dev/null | grep -Fq "'${KBD_DEVICE}'"; then
  brightnessctl -d "${KBD_DEVICE}" set "${kbd_pct}%" >/dev/null
fi

if [[ "${1:-}" == "--notify" ]]; then
  notify-send -a "Brightness" -u low -t 2500 \
    "Brightness (${mode})" \
    "Screen ${screen_pct}% · Keyboard ${kbd_pct}%"
fi
