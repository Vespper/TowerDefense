#!/usr/bin/env bash
# Lance les tests automatiques headless (tests/test_*.gd), ou ceux donnés en argument.
# N'affiche que les erreurs et les lignes « Résultat » de chaque test. Code de sortie 1 si erreur.
# Exemple : tools/test.sh tests/test_room_prototype.gd -- passive
source "$(dirname "$0")/_godot.sh"
files=()
while (($#)) && [[ "$1" != "--" ]]; do files+=("$1"); shift; done
extra=("$@")
((${#files[@]})) || mapfile -t files < <(ls tests/test_*.gd 2>/dev/null || true)
if ((${#files[@]} == 0)); then echo "Aucun test dans tests/."; exit 0; fi
status=0
for f in "${files[@]}"; do
	out="$("$GODOT" --headless --path . --fixed-fps 60 -s "res://$f" "${extra[@]}" 2>&1)" || status=1
	echo "== $f"
	grep -E 'Résultat|SCRIPT ERROR|Parse Error|ERROR:' <<<"$out" || echo "(aucune ligne « Résultat »)"
	grep -qE 'SCRIPT ERROR|Parse Error|ERROR:' <<<"$out" && status=1
done
exit $status
