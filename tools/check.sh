#!/usr/bin/env bash
# Vérifie que le projet s'importe et que tous les scripts se chargent sans erreur.
# N'affiche que les erreurs et avertissements (sortie courte). Code de sortie 1 si erreur.
source "$(dirname "$0")/_godot.sh"
log="$(mktemp)"
trap 'rm -f "$log"' EXIT
"$GODOT" --headless --path . --import >"$log" 2>&1 || true
"$GODOT" --headless --path . --quit >>"$log" 2>&1 || true
# Charge chaque script pour attraper les erreurs de parsing, même hors des scènes ouvertes.
mapfile -t scripts < <(git ls-files --cached --others --exclude-standard '*.gd' | grep -v '^tests/' || true)
if ((${#scripts[@]})); then
	checker="$(mktemp --suffix=.gd -p .)"
	trap 'rm -f "$log" "$checker"' EXIT
	{
		echo 'extends SceneTree'
		echo 'func _initialize() -> void:'
		for s in "${scripts[@]}"; do echo "	if load(\"res://$s\") == null: printerr(\"ERROR: chargement impossible res://$s\")"; done
		echo '	quit()'
	} >"$checker"
	"$GODOT" --headless --path . -s "res://${checker#./}" >>"$log" 2>&1 || true
fi
# Une ligne par problème, avec le fichier et la ligne (« at: … ») quand Godot les donne.
errors="$(awk '
	/SCRIPT ERROR|Parse Error|ERROR:|WARNING:/ { if (msg != "") print msg; msg = $0; next }
	msg != "" && /^[[:space:]]+at: / { sub(/^[[:space:]]+at: /, ""); msg = msg "  ←  " $0; print msg; msg = ""; next }
	{ if (msg != "") print msg; msg = "" }
	END { if (msg != "") print msg }
' "$log" | awk '!seen[$0]++' || true)"
if [[ -n "$errors" ]]; then
	echo "$errors"
	grep -qE 'SCRIPT ERROR|Parse Error|ERROR:' <<<"$errors" && { echo "ÉCHEC : erreurs trouvées."; exit 1; }
fi
echo "OK : ${#scripts[@]} scripts chargés sans erreur."
