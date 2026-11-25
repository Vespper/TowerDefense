class_name Armor
extends RefCounted
## Armures des ennemis neutres. Pierre-feuille-ciseaux des tours de base :
## Flèche > Léger, Mortier > Blindé, Magie > Spectral (et chaque tour de base est faible contre une autre armure).
## Qui bat quoi est réglé dans chaque TowerData (strong_against / weak_against), les multiplicateurs dans GameRules.

enum Type { NONE, LIGHT, HEAVY, SPECTRAL }

const NAMES := {
	Type.NONE: "Sans armure",
	Type.LIGHT: "Léger",
	Type.HEAVY: "Blindé",
	Type.SPECTRAL: "Spectral",
}


static func display_name(armor: Type) -> String:
	return NAMES[armor]
