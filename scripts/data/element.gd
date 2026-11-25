class_name Element
extends RefCounted
## Éléments du jeu et cycle des forces. Les multiplicateurs (fort / faible) sont dans GameRules.
## Cycle : l'Eau éteint le Feu, le Feu brûle la Nature, la Nature fend la Terre, la Terre boit l'Eau.

enum Type { NONE, FIRE, WATER, NATURE, EARTH }

const NAMES := {
	Type.NONE: "Neutre",
	Type.FIRE: "Feu",
	Type.WATER: "Eau",
	Type.NATURE: "Nature",
	Type.EARTH: "Terre",
}

const COLORS := {
	Type.NONE: Color(0.78, 0.78, 0.82),
	Type.FIRE: Color(0.95, 0.35, 0.2),
	Type.WATER: Color(0.3, 0.6, 1.0),
	Type.NATURE: Color(0.35, 0.85, 0.35),
	Type.EARTH: Color(0.8, 0.6, 0.3),
}

## Élément battu par chaque élément (attaque forte).
const BEATS := {
	Type.WATER: Type.FIRE,
	Type.FIRE: Type.NATURE,
	Type.NATURE: Type.EARTH,
	Type.EARTH: Type.WATER,
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
