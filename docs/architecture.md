# Architecture

Ne pas construire plus que l'étape en cours n'en demande.

## Dossiers

```
scenes/main/      partie (main.tscn, scène de démarrage) et apparition des vagues
scenes/board/     terrain en grille et chemin fixe
scenes/builder/   bâtisseur (personnage qui construit les tours)
scenes/towers/    tour, projectile, effets (zone, éclair)
scenes/enemies/   ennemi
scenes/ui/        HUD
scripts/data/     Resources de données (GameRules, MapData, BuilderData, TowerData, TowerBranch, EnemyData, WaveData), Element et Armor
data/             contenu de jeu en .tres : rules.tres, builder.tres, maps/, towers/, enemies/, waves/
tests/            tests headless (tools/test.sh)
tools/            scripts bash (check, test, run, screenshot)
```

## Scène principale

```
Main (Node2D, main.gd)        or, vies, stigmates, corruptions débloquées, état de la partie, pose des tours
├── Board (board.gd)          grille, chemin fixe de la MapData, terres corrompues, cases occupées ou bloquées, aperçu de pose
├── Ruins                     ruines encore debout (Ruin, scenes/ruins/ruin.gd)
├── Towers                    tours posées (Tower)
├── Enemies                   ennemis vivants (Enemy, groupe « enemies »)
├── Projectiles               projectiles et effets de zone
├── WaveSpawner               fait apparaître les ennemis d'une WaveData
├── Builder (builder.tscn)    bâtisseur : déplacement au clavier, file de chantiers
├── Camera (game_camera.gd)   suit le bâtisseur, zoom molette, clic molette glissé, C pour recentrer
└── Hud (hud.tscn)            interface ; renvoie les clics à Main par signaux
```

## Principes

- **Données séparées du code** : `GameRules` (`data/rules.tres`) pour l'économie, les stigmates et les corruptions, une `MapData` par carte (taille et coins du chemin), une `TowerData` par tour (avec ses deux `TowerBranch` en sous-ressources ; `Tower` calcule ses stats selon la branche et le niveau), une `EnemyData` par archétype, une `WaveData` par vague. Les listes de tours et de vagues sont des `@export` de `Main` (réglables dans l'inspecteur de `main.tscn`). Équilibrer = éditer un `.tres`.
- **Corruption** : `Element.Type` (enum, 6 corruptions + Neutre) avec noms, couleurs et le cycle des forces dans `scripts/data/element.gd` ; les multiplicateurs sont dans `GameRules.element_multiplier()`.
- **Signaux vers le haut, appels vers le bas** : `Enemy` émet `died` / `reached_exit`, `WaveSpawner` émet `enemy_spawned`, `Hud` émet `build_requested`, `start_wave_requested`… et `Main` décide.
- **Pas d'autoload** pour l'instant : tout l'état d'une partie est dans `Main`. En créer un (`Events`, `GameState`) seulement quand plusieurs scènes en auront besoin (menus, plusieurs cartes).
- **Dessin en code** (`_draw`) tant qu'il n'y a pas d'assets : chaque nœud se dessine lui-même avec les couleurs de son corruption.

## Carte et chemin

- `MapData.waypoints` : coins du chemin ; `path_cells()` en déduit toutes les cases. `Board` les dessine et refuse d'y construire.
- Les ennemis suivent `Board.path_points()` (bord d'entrée, coins, bord de sortie). Le ciblage « le plus avancé » utilise la distance restante (`Enemy.remaining_distance()`).
- Volants (`EnemyData.flying`) : visés seulement par les tours `hits_air` ; une zone touche sa cible volante mais pas les volants autour.

## Bâtisseur et chantiers

- `Main.try_build` paie la tour et crée une `Tower` en chantier (`build_progress` à 0, elle ne tire pas), puis la donne au bâtisseur (`Builder.order`).
- `Builder` traite sa file de `Worksite` (classe de base de `Tower` et `Ruin`, `scenes/builder/worksite.gd`) : il marche jusqu'à `build_reach` du premier chantier, appelle `work(delta)` jusqu'à ce que `is_built()` soit vrai, puis passe au suivant. Les touches de déplacement ont la priorité sur la file.
- `Main.try_upgrade` paie et rouvre le chantier (`Tower.upgrade()`, `is_upgrading()`), puis le donne aussi au bâtisseur. Durée = `build_time` × niveau visé.
- Ruines : `MapData.ruins`, créées par `Main._spawn_ruins()` ; `Main.toggle_demolition(ruin)` paie `GameRules.ruin_clear_cost` et donne la ruine au bâtisseur (ou annule et rembourse). À la fin, `Board.set_blocked(cell, false)`.
- Terres corrompues : `MapData.corrupted_cells` (case -> `Element.Type`), lues par `Board.terrain_at()` ; `Tower.terrain` est fixé à la pose et `Tower.damage()` / `poison_dps()` appliquent `GameRules.terrain_multiplier()` (bonus si même corruption, malus si opposée, `Element.opposite()`).
- Vitesse et portée dans `data/builder.tres` ; temps de construction dans chaque `TowerData.build_time`.

## Pause et caméra

- `Main` est en `PROCESS_MODE_ALWAYS`, ses enfants de jeu (Board, Ruins, Towers, Enemies, Projectiles, WaveSpawner, Builder) en `PAUSABLE`. `Main.toggle_pause()` (action `pause_game`, P) met `get_tree().paused` ; l'interface, la caméra et les ordres restent actifs, `Main._process` ne fait plus avancer le compte à rebours.
- `GameCamera` (`scenes/main/game_camera.gd`) suit `target` (le bâtisseur), limitée à la carte plus des marges pour l'interface (`set_bounds`). La souris est convertie en coordonnées du monde avec `get_canvas_transform()` (les tests font l'inverse pour cliquer).

## Vagues

- `Main.next_wave_in` : compte à rebours (`GameRules.first_wave_delay`, puis `wave_gap` après la fin des apparitions). À 0, `_launch_wave()`. `start_next_wave()` lance plus tôt et donne `GameRules.early_call_bonus()`.
- `WaveSpawner` prépare une file (normaux + élites réparties régulièrement) ; les normaux reçoivent la corruption **et** l'armure de la vague, les élites leur propre corruption.
- Dégâts : `GameRules.damage_multiplier(tour, corruption, armure)` = multiplicateur de corruption × multiplicateur d'armure (`TowerData.strong_against` / `weak_against`).
- Plusieurs vagues peuvent être sur le terrain : chaque ennemi porte son numéro de vague (`meta "wave"`), `Main` compte les vivants par vague et donne les récompenses quand une vague est vaincue (`waves_cleared`). Quand plus aucun ennemi n'est en vie, `next_wave_in` tombe à `GameRules.cleared_wave_delay`.

## Corruptions et stigmates

- `Main.elements` : corruptions débloquées ; `Main.buy_element()` dépense un stigmate. L'interface les montre sur une roue (`scenes/ui/element_wheel.gd`) : flèche = « bat », clic = débloquer. Une tour de corruption n'est disponible que si sa corruption est débloquée (`Main.is_unlocked()`).
- Fin de vague : intérêts (`GameRules.interest`), bonus, et un stigmate si `GameRules.gives_essence(n)`.

## Tests

- `tests/test_board.gd` : chemin, cases constructibles, cycle des corruptions, opposés, terres corrompues.
- `tests/test_input.gd` : souris et clavier simulés (commander une tour, attendre le bâtisseur, améliorer avec chantier et choisir la branche B avec I, vendre, débloquer une corruption, bonus et malus des terres, démolir une ruine, déplacer le bâtisseur, lancer une vague en avance).
- `tests/test_game.gd` : partie complète jouée par un joueur automatique (corruptions dans un ordre fixe, tours aux cases qui couvrent le plus de chemin) ; `-- passive` ne construit rien et doit perdre. La ligne « Résultat » sert de repère d'équilibrage.
- `Main` expose `try_build`, `try_upgrade`, `sell`, `buy_element`, `start_next_wave` pour que les tests jouent sans souris.
