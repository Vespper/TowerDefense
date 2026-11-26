class_name GameRules
extends Resource
## Règles générales d'une partie : économie, vies, éléments. Une seule instance : data/rules.tres.

@export_group("Départ")
@export var start_gold: int = 80
@export var start_lives: int = 20

@export_group("Économie")
## Or gagné à la fin de chaque vague : base + par_vague × numéro de la vague (1, 2, 3…).
@export var wave_bonus_base: int = 10
@export var wave_bonus_per_wave: int = 2
## Intérêts versés en fin de vague sur l'or gardé (0.03 = 3 %).
@export var interest_rate: float = 0.03
## Part du total dépensé (pose + améliorations) rendue à la revente.
@export_range(0.0, 1.0) var sell_refund: float = 0.75

@export_group("Vagues")
## Secondes avant la première vague.
@export var first_wave_delay: float = 30.0
## Secondes entre la fin des apparitions d'une vague et le début de la suivante.
@export var wave_gap: float = 30.0
## Or gagné par seconde d'avance quand on lance la vague suivante soi-même.
@export var early_call_gold_per_second: float = 0.5

@export_group("Stigmates")
## Une essence (« stigmate » en jeu) débloque une corruption (et ses tours). On en a au départ, puis on en gagne avec les vagues.
@export var start_essences: int = 1
## Une essence de plus à la fin de chaque vague multiple de ce nombre.
@export var essence_every_waves: int = 4

@export_group("Tours")
@export var max_tower_level: int = 3

@export_group("Armures")
## Multiplicateur d'une tour de base contre l'armure qu'elle bat (ex. Arbalète contre Chair).
@export var armor_strong_multiplier: float = 1.5
## Multiplicateur d'une tour de base contre l'armure qui lui résiste (ex. Arbalète contre Carapace).
@export var armor_weak_multiplier: float = 0.5

@export_group("Vagues (suite)")
## Quand toutes les vagues lancées sont vaincues, le compte à rebours de la suivante tombe à cette valeur.
@export var cleared_wave_delay: float = 3.0

@export_group("Corruptions")
## Multiplicateur de dégâts d'une attaque forte (ex. Eau contre Feu).
@export var strong_multiplier: float = 2.0
## Multiplicateur de dégâts d'une attaque faible (ex. Feu contre Eau).
@export var weak_multiplier: float = 0.5


func element_multiplier(attack: Element.Type, defense: Element.Type) -> float:
	match Element.matchup(attack, defense):
		1:
			return strong_multiplier
		-1:
			return weak_multiplier
	return 1.0


func armor_multiplier(tower: TowerData, armor: Armor.Type) -> float:
	if armor == Armor.Type.NONE:
		return 1.0
	if armor == tower.strong_against:
		return armor_strong_multiplier
	if armor == tower.weak_against:
		return armor_weak_multiplier
	return 1.0


## Multiplicateur total d'un coup de cette tour sur cet ennemi (élément × armure).
func damage_multiplier(tower: TowerData, element: Element.Type, armor: Armor.Type) -> float:
	return element_multiplier(tower.element, element) * armor_multiplier(tower, armor)


func wave_bonus(wave_number: int) -> int:
	return wave_bonus_base + wave_bonus_per_wave * wave_number


func interest(gold: int) -> int:
	return int(floor(gold * interest_rate))


## Vrai si la fin de cette vague (1, 2, 3…) donne une essence.
func gives_essence(wave_number: int) -> bool:
	return essence_every_waves > 0 and wave_number % essence_every_waves == 0


## Or gagné en lançant la vague avec `seconds_left` secondes d'avance.
func early_call_bonus(seconds_left: float) -> int:
	return int(floor(maxf(seconds_left, 0.0) * early_call_gold_per_second))
