#!/usr/bin/env bash
# Joue une partie automatique et enregistre une capture d'écran après N secondes de jeu.
# Usage : tools/screenshot.sh [secondes=60] [fichier=screenshot.png]
# Sous Linux sans écran, passe par xvfb-run s'il est installé.
source "$(dirname "$0")/_godot.sh"
seconds="${1:-60}"
out="$(realpath -m "${2:-screenshot.png}")"
run=("$GODOT" --path . --fixed-fps 60 --resolution 1280x720 -s res://tests/test_game.gd -- "shot=$seconds" "out=$out")
if [[ -z "${DISPLAY:-}" && "$(uname)" == "Linux" ]] && command -v xvfb-run >/dev/null; then
	run=(xvfb-run -a -s "-screen 0 1280x720x24" "${run[@]}")
fi
"${run[@]}" 2>&1 | grep -E 'Résultat|SCRIPT ERROR|Parse Error' || true
