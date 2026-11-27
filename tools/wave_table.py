#!/usr/bin/env python3
"""Régénère le tableau des vagues de docs/wiki/vagues.md à partir de data/waves/*.tres.

Usage : python3 tools/wave_table.py   (réécrit le tableau en place)
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CORRUPTIONS = ["Neutre", "Ferveur", "Démence", "Abîme", "Cendre", "Pourriture", "Os"]
ARMORS = ["—", "Chair", "Carapace", "Spectre"]


def fields(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    ext = dict(re.findall(r'\[ext_resource [^\]]*path="([^"]+)" id="([^"]+)"\]', text))
    ext = {v: k for k, v in ext.items()}
    out = {}
    for key, value in re.findall(r"^(\w+) = (.+)$", text, re.M):
        m = re.match(r'ExtResource\("([^"]+)"\)', value)
        out[key] = ext[m.group(1)] if m else value.strip('"')
    return out


def enemy(res_path: str) -> dict:
    return fields(ROOT / res_path.replace("res://", ""))


def num(x: float) -> str:
    return f"{x:g}".replace(".", ",")


rows = []
for path in sorted((ROOT / "data/waves").glob("wave_*.tres")):
    w = fields(path)
    n = int(path.stem.split("_")[1])
    e = enemy(w["enemy"])
    mult = float(w.get("health_multiplier", 1))
    element = int(w.get("element", 0))
    kind = CORRUPTIONS[element] if element else ARMORS[int(w.get("armor", 0))]
    elites = "—"
    if "elite" in w and int(w.get("elite_count", 0)) > 0:
        el = enemy(w["elite"])
        elites = f'{w["elite_count"]} × {el["display_name"]} {CORRUPTIONS[int(w.get("elite_element", 0))]} ({round(float(el["max_health"]) * mult)} PV)'
    rows.append(f'| {n} | {e["display_name"]} | {kind} | {w.get("count", 10)} | {num(float(w.get("spawn_interval", 1)))} | {num(mult)} | {round(float(e["max_health"]) * mult)} | {elites} |')

wiki = ROOT / "docs/wiki/vagues.md"
text = wiki.read_text(encoding="utf-8")
header = "| # | Archétype | Type | Nombre | Intervalle (s) | × PV | PV par ennemi | Élites |\n|---|---|---|---|---|---|---|---|\n"
start = text.index(header) + len(header)
end = start
lines = text[start:].split("\n")
count = 0
while count < len(lines) and lines[count].startswith("|"):
    count += 1
rest = "\n".join(lines[count:])
wiki.write_text(text[:start] + "\n".join(rows) + "\n" + rest, encoding="utf-8")
print("OK : %d vagues dans docs/wiki/vagues.md" % len(rows))
