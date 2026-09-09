#!/bin/bash
# Genera el mensaje con IA y abre el editor para que lo revises/edites antes de confirmar el commit.
set -euo pipefail

msg=$(mktemp)
trap 'rm -f "$msg"' EXIT

~/.config/lazygit/scripts/ai-commit-msg.sh > "$msg"
git commit -e -F "$msg"
