class_name Element
extends RefCounted
## Les six éléments d'Element TD et leur cycle. Les multiplicateurs (fort / faible) sont dans GameRules.
## Cycle : Lumière > Ténèbres > Eau > Feu > Nature > Terre > Lumière.
## Chaque élément fait double dégâts à celui qu'il bat, et moitié à celui qui le bat.

enum Type { NONE, LIGHT, DARKNESS, WATER, FIRE, NATURE, EARTH }

## Les éléments jouables, dans l'ordre du cycle (pour l'interface).
const ALL: Array[Type] = [Type.LIGHT, Type.DARKNESS, Type.WATER, Type.FIRE, Type.NATURE, Type.EARTH]

const NAMES := {
	Type.NONE: "Neutre",
	Type.LIGHT: "Lumière",
	Type.DARKNESS: "Ténèbres",
	Type.WATER: "Eau",
	Type.FIRE: "Feu",
	Type.NATURE: "Nature",
	Type.EARTH: "Terre",
}

const COLORS := {
	Type.NONE: Color(0.78, 0.78, 0.82),
	Type.LIGHT: Color(1.0, 0.95, 0.55),
	Type.DARKNESS: Color(0.65, 0.35, 0.9),
	Type.WATER: Color(0.3, 0.6, 1.0),
	Type.FIRE: Color(0.95, 0.35, 0.2),
	Type.NATURE: Color(0.35, 0.85, 0.35),
	Type.EARTH: Color(0.8, 0.6, 0.3),
}

## Élément battu par chaque élément (attaque forte).
const BEATS := {
	Type.LIGHT: Type.DARKNESS,
	Type.DARKNESS: Type.WATER,
	Type.WATER: Type.FIRE,
	Type.FIRE: Type.NATURE,
	Type.NATURE: Type.EARTH,
	Type.EARTH: Type.LIGHT,
}


static func display_name(element: Type) -> String:
	return NAMES[element]


static func color(element: Type) -> Color:
	return COLORS[element]


## 1 si l'attaque est forte contre la défense, -1 si elle est faible, 0 sinon (ou si l'un est neutre).
static func matchup(attack: Type, defense: Type) -> int:
	if attack == Type.NONE or defense == Type.NONE:
		return 0
	if BEATS.get(attack, -1) == defense:
		return 1
	if BEATS.get(defense, -1) == attack:
		return -1
	return 0
