class_name TowerData
extends Resource
## Un type de tour (niveau 1). Les améliorations multiplient les dégâts.
## Une tour d'élément demande d'avoir débloqué cet élément ; une tour neutre est toujours disponible.

@export var display_name: String = "Tour"
@export var element: Element.Type = Element.Type.NONE
@export_multiline var description: String = ""
@export var cost: int = 10
## Secondes de construction par le bâtisseur, une fois arrivé à côté de la case.
@export var build_time: float = 1.5

@export_group("Attaque")
@export var damage: float = 5.0
## Tirs par seconde.
@export var fire_rate: float = 1.0
## Portée en pixels (une case = 40 px).
@export var attack_range: float = 120.0
@export var projectile_speed: float = 420.0
## Peut viser les ennemis volants.
@export var hits_air: bool = true

@export_group("Effets")
## Rayon des dégâts de zone autour de l'impact (0 = cible seule). La zone ne touche pas les volants.
@export var splash_radius: float = 0.0
## Nombre d'ennemis de plus touchés par rebond (0 = pas de rebond).
@export var chain_count: int = 0
## Distance maximale d'un rebond.
@export var chain_range: float = 90.0
## Vitesse restante d'un ennemi ralenti (0.6 = 40 % plus lent). 1 = pas de ralentissement.
@export_range(0.1, 1.0) var slow_factor: float = 1.0
@export var slow_duration: float = 0.0
## Dégâts par seconde du poison (0 = pas de poison).
@export var poison_dps: float = 0.0
@export var poison_duration: float = 0.0

@export_group("Améliorations")
## Coût de l'amélioration vers le niveau N+1 = coût × ratio × N.
@export var upgrade_cost_ratio: float = 0.75
## Multiplicateur des dégâts (et du poison) à chaque niveau.
@export var upgrade_damage_multiplier: float = 1.6


func damage_at(level: int) -> float:
	return damage * pow(upgrade_damage_multiplier, level - 1)


func poison_at(level: int) -> float:
	return poison_dps * pow(upgrade_damage_multiplier, level - 1)


func upgrade_cost(from_level: int) -> int:
	return int(round(cost * upgrade_cost_ratio * from_level))

