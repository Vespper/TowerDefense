# Architecture

Ne pas construire plus que l'étape en cours n'en demande.

## Dossiers

```
scenes/main/      partie (main.tscn, scène de démarrage) et apparition des vagues
scenes/board/     terrain en grille et chemin fixe
scenes/towers/    tour, projectile, effets (zone, éclair)
scenes/enemies/   ennemi
scenes/ui/        HUD
scripts/data/     Resources de données (GameRules, MapData, TowerData, EnemyData, WaveData) et Element
data/             contenu de jeu en .tres : rules.tres, maps/, towers/, enemies/, waves/
tests/            tests headless (tools/test.sh)
tools/            scripts bash (check, test, run, screenshot)
```

## Scène principale

```
Main (Node2D, main.gd)        or, vies, essences, éléments débloqués, état de la partie, pose des tours
├── Board (board.gd)          grille, chemin fixe de la MapData, cases occupées, aperçu de pose
├── Towers                    tours posées (Tower)
├── Enemies                   ennemis vivants (Enemy, groupe « enemies »)
├── Projectiles               projectiles et effets de zone
├── WaveSpawner               fait apparaître les ennemis d'une WaveData
└── Hud (hud.tscn)            interface ; renvoie les clics à Main par signaux
```

## Principes

- **Données séparées du code** : `GameRules` (`data/rules.tres`) pour l'économie, les essences et les éléments, une `MapData` par carte (taille et coins du chemin), une `TowerData` par tour, une `EnemyData` par archétype, une `WaveData` par vague. Les listes de tours et de vagues sont des `@export` de `Main` (réglables dans l'inspecteur de `main.tscn`). Équilibrer = éditer un `.tres`.
- **Élément** : `Element.Type` (enum, 6 éléments + Neutre) avec noms, couleurs et le cycle des forces dans `scripts/data/element.gd` ; les multiplicateurs sont dans `GameRules.element_multiplier()`.
- **Signaux vers le haut, appels vers le bas** : `Enemy` émet `died` / `reached_exit`, `WaveSpawner` émet `enemy_spawned`, `Hud` émet `build_requested`, `start_wave_requested`… et `Main` décide.
- **Pas d'autoload** pour l'instant : tout l'état d'une partie est dans `Main`. En créer un (`Events`, `GameState`) seulement quand plusieurs scènes en auront besoin (menus, plusieurs cartes).
- **Dessin en code** (`_draw`) tant qu'il n'y a pas d'assets : chaque nœud se dessine lui-même avec les couleurs de son élément.

## Carte et chemin

- `MapData.waypoints` : coins du chemin ; `path_cells()` en déduit toutes les cases. `Board` les dessine et refuse d'y construire.
- Les ennemis suivent `Board.path_points()` (bord d'entrée, coins, bord de sortie). Le ciblage « le plus avancé » utilise la distance restante (`Enemy.remaining_distance()`).
- Volants (`EnemyData.flying`) : visés seulement par les tours `hits_air` ; une zone touche sa cible volante mais pas les volants autour.

## Éléments et essences

- `Main.elements` : éléments débloqués ; `Main.buy_element()` dépense une essence. Une tour d'élément n'est disponible que si son élément est débloqué (`Main.is_unlocked()`).
- Fin de vague : intérêts (`GameRules.interest`), bonus, et une essence si `GameRules.gives_essence(n)`.

## Tests

- `tests/test_board.gd` : chemin, cases constructibles, cycle des éléments.
- `tests/test_input.gd` : souris et clavier simulés (poser, améliorer, vendre, débloquer un élément).
- `tests/test_game.gd` : partie complète jouée par un joueur automatique (éléments dans un ordre fixe, tours aux cases qui couvrent le plus de chemin) ; `-- passive` ne construit rien et doit perdre. La ligne « Résultat » sert de repère d'équilibrage.
- `Main` expose `try_build`, `try_upgrade`, `sell`, `buy_element`, `start_next_wave` pour que les tests jouent sans souris.
