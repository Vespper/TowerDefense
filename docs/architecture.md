# Architecture

Ne pas construire plus que l'étape en cours n'en demande.

## Dossiers

```
scenes/main/      partie (main.tscn, scène de démarrage) et apparition des vagues
scenes/board/     terrain en grille et recherche de chemin
scenes/towers/    tour, projectile, effet de zone
scenes/enemies/   ennemi
scenes/ui/        HUD
scripts/data/     Resources de données (GameRules, TowerData, EnemyData, WaveData) et Element
data/             contenu de jeu en .tres : rules.tres, towers/, enemies/, waves/
tests/            tests headless (tools/test.sh)
tools/            scripts bash (check, test, run, screenshot)
```

## Scène principale

```
Main (Node2D, main.gd)        or, vies, état (construction / vague / victoire / défaite), pose des tours
├── Board (board.gd)          grille, AStarGrid2D, chemin, aperçu de pose
├── Towers                    tours posées (Tower)
├── Enemies                   ennemis vivants (Enemy, groupe « enemies »)
├── Projectiles               projectiles et effets de zone
├── WaveSpawner               fait apparaître les ennemis d'une WaveData
└── Hud (hud.tscn)            interface ; renvoie les clics à Main par signaux
```

## Principes

- **Données séparées du code** : `GameRules` (`data/rules.tres`) pour l'économie et les éléments, une `TowerData` par tour, une `EnemyData` par archétype, une `WaveData` par vague. Les listes de tours et de vagues sont des `@export` de `Main` (réglables dans l'inspecteur de `main.tscn`). Équilibrer = éditer un `.tres`.
- **Élément** : `Element.Type` (enum) avec noms, couleurs et le cycle des forces dans `scripts/data/element.gd` ; les multiplicateurs sont dans `GameRules.element_multiplier()`.
- **Signaux vers le haut, appels vers le bas** : `Enemy` émet `died` / `reached_exit`, `WaveSpawner` émet `enemy_spawned`, `Board` émet `path_changed` (les ennemis recalculent leur chemin), `Hud` émet `build_requested`, `start_wave_requested`… et `Main` décide.
- **Pas d'autoload** pour l'instant : tout l'état d'une partie est dans `Main`. En créer un (`Events`, `GameState`) seulement quand plusieurs scènes en auront besoin (menus, plusieurs cartes).
- **Dessin en code** (`_draw`) tant qu'il n'y a pas d'assets : chaque nœud se dessine lui-même avec les couleurs de son élément.

## Labyrinthe

- `Board` garde un `AStarGrid2D` (sans diagonale). Une tour posée rend sa case « solide ».
- `Board.can_build(case, positions_ennemis)` : refuse l'entrée, la sortie, une case prise, une case sous un ennemi, et toute pose qui couperait le chemin depuis l'entrée ou depuis un ennemi.
- Un ennemi suit une liste de centres de case ; à `path_changed`, il repart de la case où il se trouve. Le ciblage « le plus avancé » utilise la distance restante sur son chemin (`Enemy.remaining_distance()`).

## Tests

- `tests/test_board.gd` : règles du terrain et des éléments.
- `tests/test_game.gd` : partie complète jouée par un joueur automatique (serpentin de Flèches avec des tours élémentaires) ; `-- passive` ne construit rien et doit perdre. La ligne « Résultat » sert de repère d'équilibrage.
- `Main` expose `try_build`, `try_upgrade`, `sell`, `start_next_wave` pour que les tests jouent sans souris.
