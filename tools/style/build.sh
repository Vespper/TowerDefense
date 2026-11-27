#!/usr/bin/env bash
# Régénère les planches de style dans docs/design/img/style/ (Python 3 + Pillow, Node + Playwright).
set -e
here="$(cd "$(dirname "$0")" && pwd)"
out="$(mktemp -d)"
python3 "$here/gen_svg.py" "$out"
python3 "$here/gen_pixel.py" "$out"
cd "$out"
node "$here/shot.js" "$out/scene_a.svg" scene_a.png 1024 640
node "$here/shot.js" "$out/scene_c.svg" scene_c.png 1024 640
mv b.png scene_b.png
python3 "$here/sheet.py"
for k in a b c; do node "$here/shot.js" "$out/sheet_$k.html" "$here/../../docs/design/img/style/planche_$k.png" 1600 900; done
echo "OK : docs/design/img/style/planche_{a,b,c}.png"
