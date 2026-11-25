class_name WaveData
extends Resource
## Une vague : un archétype d'ennemi, un élément ou une armure, un nombre et un rythme d'apparition,
## et éventuellement quelques élites (avec leur propre élément) mêlés au groupe.

@export var enemy: EnemyData
@export var element: Element.Type = Element.Type.NONE
## Armure des ennemis (pour les vagues neutres ; une vague d'élément n'en a pas en général).
@export var armor: Armor.Type = Armor.Type.NONE
@export var count: int = 10
## Secondes entre deux apparitions.
@export var spawn_interval: float = 0.8
## Multiplicateur des PV de l'archétype pour cette vague.
@export var health_multiplier: float = 1.0

@export_group("Élites")
## Archétype des élites (vide = pas d'élite).
@export var elite: EnemyData
@export var elite_count: int = 0
@export var elite_element: Element.Type = Element.Type.NONE
