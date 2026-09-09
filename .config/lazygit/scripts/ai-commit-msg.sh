#!/bin/bash
# Genera un mensaje de commit con IA (Claude) siguiendo la convencion de dai,
# a partir del diff stageado. Imprime SOLO el mensaje por stdout.
set -euo pipefail

diff=$(git diff --staged)
if [ -z "$diff" ]; then
    echo "No hay cambios en el stage (hace git add primero)." >&2
    exit 1
fi

prompt="Sos un generador de mensajes de commit. Analiza el diff de abajo y devolve UNICAMENTE el texto del mensaje de commit -- sin explicaciones, sin markdown, sin comillas ni backticks, sin texto antes o despues.

Formato exacto (convencion del proyecto, ver dai/governance/commit-convention.md):
<tipo>(<scope>)!: <resumen>

<cuerpo opcional>

Reglas:
- tipo: uno de feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- scope: opcional, minusculas, entre parentesis (ej: cart, auth, cli); omitilo si no aplica claramente
- '!' opcional pegado despues del tipo/scope, solo si es un breaking change
- resumen: obligatorio, en espanol, modo imperativo (ej: 'agrega validacion de stock', NO 'agregado' ni 'se agrega'), minusculas, SIN punto final, maximo 72 caracteres
- cuerpo: opcional, solo si el cambio no es obvio por el resumen; explica el POR QUE, no el que
- Prohibido: no agregues 'Co-authored-by', no menciones IA/Claude/Copilot ni ningun asistente en el mensaje -- el commit lo firma una persona

Diff:
${diff}"

echo "$prompt" | claude -p --tools ""
