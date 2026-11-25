class_name TowerBranch
extends Resource
## Une branche d'amélioration d'une tour. Au niveau 2 on choisit l'une des deux branches de la tour ;
## le niveau 3 renforce la même branche. Chaque niveau au-dessus de 1 applique ces bonus une fois de plus.

@export var display_name: String = "Branche"
@export_multiline var description: String = ""
## Multiplicateurs appliqués à chaque niveau (1 = pas de changement).
@export var damage_mult: float = 1.0
@export var fire_rate_mult: float = 1.0
@export var range_mult: float = 1.0
@export var poison_mult: float = 1.0
## Bonus ajoutés à chaque niveau.
@export var splash_bonus: float = 0.0
@export var chain_bonus: int = 0
## Ralentissement supplémentaire (0.1 = la cible garde 10 % de vitesse en moins).
@export var slow_bonus: float = 0.0
