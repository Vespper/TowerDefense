# Direction artistique

Ton **grimdark**, inspiration Vermis : un monde sale et sombre où seules les corruptions apportent de la couleur. Chaque corruption garde sa couleur (`scripts/data/element.gd`, roue : `img/corruptions.svg`) : Ferveur or terni, Démence violet maladif, Abîme bleu-noir, Cendre braise, Os ivoire sale, Pourriture vert bile, Neutre gris.

Règles de lisibilité, quel que soit le style retenu :

- Le chemin se distingue du sol au premier coup d'œil (valeur plus claire ou plus chaude).
- La couleur vive est réservée aux corruptions : décor, tours de base et ennemis neutres restent dans les gris, bruns et ivoires.
- Une tour se reconnaît à sa silhouette, une corruption à sa couleur.
- Tout reste lisible à l'échelle réelle (cases de 40 px).

## Planches de style (à choisir)

Même morceau de carte dans les trois : sol, chemin, Arbalète, tour de Pourriture, ennemi de Cendre empoisonné, ruines. Régénérer avec `tools/style/build.sh`.

| Direction | Idée | Pour | Contre |
|---|---|---|---|
| [A, Gravure](img/style/planche_a.png) | Encre noire sur papier sale, une seule couleur : la corruption | Le plus proche de Vermis, très original | Le plus long à produire, risque de bruit visuel avec beaucoup d'unités |
| [B, Pixel art lugubre](img/style/planche_b.png) | Cases de 16 px, palette sombre restreinte | Rapide à produire, très lisible | Moins singulier, zoom entier obligatoire |
| [C, Silhouettes et lueurs](img/style/planche_c.png) | Monde presque noir, seules les corruptions émettent de la lumière | Proche du code actuel, ambiance immédiate | Peut manquer de détail, coût des halos |
| [D, Lueurs gravées](img/style/planche_d.png) | Base C, décor gravé peu contrasté (Vermis), éléments de jeu à contour noir épais (Isaac) | Ambiance Vermis et lisibilité Isaac | Deux couches de style à tenir, un peu plus « cartoon » |

Orientation de Vespper (27/11) : **Vermis pour l'ambiance générale, lisibilité proche d'Isaac**, donc une base C. La planche D est la proposition qui en découle, à valider avant de la noter dans `docs/decisions.md`.

Règles de D :

- Décor (sol, hachures, herbes) : sombre, gravé, faible contraste. Il ne doit jamais attirer l'œil.
- Éléments de jeu (tours, ennemis, ruines, projectiles) : contour noir épais, valeurs moyennes, formes simples et un peu grosses.
- Couleur vive et halo : seulement les corruptions (tours, ennemis, effets).
- Grain papier léger et vignette sur tout l'écran.

## Outils

- `tools/style/` : scripts Python qui dessinent les planches (SVG pour A et C, Pillow pour B) puis les capturent avec Playwright.
- Blender 5.3 est utilisable en script (`blender --background --python script.py`) sur le poste de Vespper ; les scripts Blender iront dans `tools/blender/`.
