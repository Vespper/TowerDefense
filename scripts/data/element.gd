class_name Element
extends RefCounted
## Les six corruptions et leur cycle (dans le code, on garde le nom « Element »).
## Les multiplicateurs (fort / faible) sont dans GameRules.
## Cycle : Ferveur > Démence > Abîme > Cendre > Os > Pourriture > Ferveur.
## Chaque corruption fait double dégâts à celle qu'elle bat, et moitié à celle qui la bat.
## Les valeurs de l'enum sont enregistrées dans les .tres : ne pas changer leur ordre.

enum Type { NONE, FERVOR, MADNESS, ABYSS, ASH, ROT, BONE }

## Les corruptions jouables, dans l'ordre du cycle (pour l'interface).
const ALL: Array[Type] = [Type.FERVOR, Type.MADNESS, Type.ABYSS, Type.ASH, Type.BONE, Type.ROT]

const NAMES := {
	Type.NONE: "Neutre",
	Type.FERVOR: "Ferveur",
	Type.MADNESS: "Démence",
	Type.ABYSS: "Abîme",
	Type.ASH: "Cendre",
	Type.ROT: "Pourriture",
	Type.BONE: "Os",
}

## Palette sombre : or terni, violet maladif, bleu-noir, braise, vert bile, ivoire sale.
const COLORS := {
	Type.NONE: Color(0.72, 0.7, 0.66),
	Type.FERVOR: Color(0.86, 0.68, 0.25),
	Type.MADNESS: Color(0.66, 0.4, 0.82),
	Type.ABYSS: Color(0.3, 0.55, 0.78),
	Type.ASH: Color(0.86, 0.37, 0.18),
	Type.ROT: Color(0.55, 0.7, 0.22),
	Type.BONE: Color(0.86, 0.82, 0.7),
}

## Corruption battue par chaque corruption (attaque forte).
const BEATS := {
	Type.FERVOR: Type.MADNESS,
	Type.MADNESS: Type.ABYSS,
	Type.ABYSS: Type.ASH,
	Type.ASH: Type.BONE,
	Type.BONE: Type.ROT,
	Type.ROT: Type.FERVOR,
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
