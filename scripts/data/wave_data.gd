class_name WaveData
extends Resource
## Une vague : un archétype d'ennemi, un élément, un nombre et un rythme d'apparition.

@export var enemy: EnemyData
@export var element: Element.Type = Element.Type.NONE
@export var count: int = 10
## Secondes entre deux apparitions.
@export var spawn_interval: float = 0.8
## Multiplicateur des PV de l'archétype pour cette vague.
@export var health_multiplier: float = 1.0
