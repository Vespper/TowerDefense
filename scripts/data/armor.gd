class_name Armor
extends RefCounted
## Armures des ennemis neutres. Pierre-feuille-ciseaux des tours de base :
## Arbalète > Chair, Trébuchet > Carapace, Encensoir > Spectre (et chaque tour de base est faible contre une autre armure).
## Qui bat quoi est réglé dans chaque TowerData (strong_against / weak_against), les multiplicateurs dans GameRules.

enum Type { NONE, FLESH, CARAPACE, SPECTER }

const NAMES := {
	Type.NONE: "Sans armure",
	Type.FLESH: "Chair",
	Type.CARAPACE: "Carapace",
	Type.SPECTER: "Spectre",
}


static func display_name(armor: Type) -> String:
	return NAMES[armor]
