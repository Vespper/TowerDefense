class_name GameRules
extends Resource
## Règles générales d'une partie : économie, vies, éléments. Une seule instance : data/rules.tres.

@export_group("Départ")
@export var start_gold: int = 80
@export var start_lives: int = 20

@export_group("Économie")
## Or gagné à la fin de chaque vague : base + par_vague × numéro de la vague (1, 2, 3…).
@export var wave_bonus_base: int = 15
@export var wave_bonus_per_wave: int = 3
## Part du total dépensé (pose + améliorations) rendue à la revente.
@export_range(0.0, 1.0) var sell_refund: float = 0.75

@export_group("Tours")
@export var max_tower_level: int = 3

@export_group("Éléments")
## Multiplicateur de dégâts d'une attaque forte (ex. Eau contre Feu).
@export var strong_multiplier: float = 1.5
## Multiplicateur de dégâts d'une attaque faible (ex. Feu contre Eau).
@export var weak_multiplier: float = 0.75


func element_multiplier(attack: Element.Type, defense: Element.Type) -> float:
	match Element.matchup(attack, defense):
		1:
			return strong_multiplier
		-1:
			return weak_multiplier
	return 1.0


func wave_bonus(wave_number: int) -> int:
	return wave_bonus_base + wave_bonus_per_wave * wave_number
