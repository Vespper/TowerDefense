#!/usr/bin/env bash
# Trouve l'exécutable Godot. Sourcé par les autres scripts de tools/.
# Ordre : variable GODOT, puis tools/local.env (non versionné), puis godot / godot4 dans le PATH.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "${GODOT:-}" && -f "$ROOT/tools/local.env" ]]; then
	# shellcheck disable=SC1091
	source "$ROOT/tools/local.env"
fi
if [[ -z "${GODOT:-}" ]]; then
	GODOT="$(command -v godot || command -v godot4 || true)"
fi
if [[ -z "$GODOT" || ! -x "$GODOT" ]] && ! command -v "$GODOT" >/dev/null 2>&1; then
	echo "Godot introuvable. Copier tools/local.env.example en tools/local.env et y mettre le chemin de Godot (version console sous Windows)." >&2
	exit 2
fi
cd "$ROOT"
