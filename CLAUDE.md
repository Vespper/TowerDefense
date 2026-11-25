# TowerDefense — mémo pour Claude

Tower defense **classique** en **Godot 4.7 / GDScript**, inspiré d'Element TD (mod Warcraft 3) : on construit un labyrinthe avec ses tours sur un terrain ouvert, les tours ont des éléments, chaque vague a un élément. Deuxième projet de Vespper : on fait d'abord un tower defense solide, il sera intégré plus tard au roguelike (`Vespper/Gameproject`, en pause).

Réponds et documente **en français**, en tutoyant Vespper. Code (identifiants) en anglais, commentaires en français.

## Charger seulement ce qui sert

Ne lis pas tout `docs/` d'office. Ouvre le fichier utile à la tâche :

| Besoin | Fichier |
|---|---|
| Où on en est, tâche suivante | `docs/roadmap.md` |
| Règles du jeu, boucle, éléments, économie | `docs/design/gdd.md` |
| Catalogue du contenu (tours, ennemis, vagues, éléments) et ses stats | `docs/wiki/` (commencer par `README.md`) |
| Organisation du code, scènes, données | `docs/architecture.md` |
| Style GDScript, nommage, git, PR | `docs/conventions.md` |
| Poste de travail, commandes | `docs/setup.md` (chemins de la machine : `docs/setup.local.md`, non versionné) |
| Décisions déjà prises (ne pas les rediscuter) | `docs/decisions.md` |

## Règles qui s'appliquent toujours

- Itérer pas à pas : une petite étape jouable à la fois, une PR par étape.
- Données de jeu dans `data/*.tres` (Resources), pas en dur dans le code.
- Quand on ajoute ou change du contenu (tour, ennemi, vague, élément), mettre à jour sa ligne dans `docs/wiki/` dans la même PR.
- Une scène et son script dans le même dossier, fichiers en `snake_case`.
- Ne jamais committer `.godot/` ni éditer `project.godot` à la main sans raison (les touches se règlent dans l'éditeur : Projet > Paramètres > Contrôles).
- Après un changement d'équilibrage, lancer `tools/test.sh` et noter la ligne « Résultat » de `test_game.gd` dans la PR.
- Vespper teste dans l'éditeur (F5) : décrire à chaque PR quoi tester et quoi ressentir.
- Fin de session : lancer la skill `fin-de-session` pour mettre à jour `docs/roadmap.md` (et `docs/decisions.md` si une décision a été prise).

## Git : c'est Claude qui gère tout

Vespper ne touche pas à git. Claude s'en charge de bout en bout, sans lui demander de le faire :

- créer la branche, committer, pousser, ouvrir la PR ;
- fusionner la PR quand l'étape est prête (CI et tests au vert), sans attendre que Vespper le fasse ;
- puis mettre à jour le clone local de Vespper (chemin dans `docs/setup.local.md`) : vérifier qu'il n'y a pas de modifications non commitées, `git checkout main`, `git pull` ;
- lui dire ensuite quoi tester avec F5.

S'il y a des modifications locales non commitées dans son clone, ne rien écraser et lui demander.

## Scripts (préférer à des commandes Godot écrites à la main)

- `tools/check.sh` : erreurs de script (fichier et ligne), sinon « OK ». À lancer après chaque modification de `.gd`, `.tscn` ou `.tres`.
- `tools/test.sh` : tests headless `tests/test_*.gd`, n'affiche que les résultats (dont une partie complète jouée automatiquement).
- `tools/screenshot.sh [secondes] [fichier]` : partie automatique et capture d'écran, pour vérifier un changement visuel sans ouvrir l'éditeur.
- `tools/run.sh` : lance le jeu.

Une commande répétée plusieurs fois ou à la sortie trop longue mérite un script dans `tools/` : l'ajouter et le lister ici.

## Données privées

Le dépôt est public : aucun chemin de la machine, nom de dossier personnel ou identifiant dans les fichiers versionnés. Ils vont dans `docs/setup.local.md` ou `tools/local.env`.

## Agents

- `godot-dev` : écrire ou corriger scènes et GDScript.
- `game-designer` : règles, équilibrage, contenu (tours, ennemis, vagues), mise à jour du GDD.
