# Conventions

## GDScript

- Suivre le [guide de style officiel](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) : tabulations, `snake_case` pour variables et fonctions, `PascalCase` pour classes et nœuds, `CONSTANT_CASE` pour constantes.
- **Typage statique partout** : `var speed: float = 120.0`, `func take_damage(amount: float) -> void:`.
- Ordre dans un script : `class_name`, `extends`, doc `##`, signaux, enums, constantes, `@export`, variables, `@onready`, fonctions du moteur (`_ready`, `_process`…), fonctions publiques, fonctions privées (`_prefixe`).
- Signaux au passé : `died`, `reached_exit`, `path_changed`.
- Pas de chemins de nœuds en dur fragiles : `@onready var hud: Hud = $Hud`, `%NomUnique` dans l'interface, ou `@export` pour les références.
- Identifiants en anglais, commentaires et docs en français.

## Fichiers

- `snake_case` partout : `tower.tscn`, `tower.gd`, `fire.tres`.
- Une scène et son script côte à côte. Les Resources de données dans `data/<type>/`.
- Ne pas committer `.godot/`. Laisser Godot gérer les `.import` et `.uid` (les committer).

## Git et PR

- Claude gère git de bout en bout (voir `CLAUDE.md`).
- Une branche et une PR par étape de la feuille de route. `main` reste toujours jouable.
- Messages de commit en français, à l'impératif : « Ajoute la tour de Feu ».
- Chaque PR suit `.github/pull_request_template.md` : ce qui change, comment tester (F5, quoi regarder, quoi ressentir), résultat des tests, ce qui reste.
- La CI (`.github/workflows/ci.yml`) lance `tools/check.sh` et `tools/test.sh` avec Godot headless : on ne fusionne que si elle est verte.
- Assets lourds (.blend, .wav, grosses textures) : activer Git LFS avant le premier ajout.

## Équilibrage

- Les chiffres vivent dans `data/*.tres`, jamais en dur.
- Après un changement, lancer `tools/test.sh` et recopier la ligne « Résultat » de `test_game.gd` dans la PR. Repère actuel : le joueur automatique gagne avec environ la moitié de ses vies (8 sur 20 avec les armures et les élites ; Vespper fait mieux que lui). S'il gagne sans perdre de vie, c'est trop facile ; s'il perd tôt, trop dur.
