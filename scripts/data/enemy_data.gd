class_name EnemyData
extends Resource
## Un archétype d'ennemi. Son élément et sa résistance viennent de la vague (WaveData).

@export var display_name: String = "Ennemi"
@export var max_health: float = 30.0
## Vitesse en pixels par seconde (une case = 40 px).
@export var speed: float = 60.0
## Or gagné quand il meurt.
@export var bounty: int = 2
## Vies perdues s'il atteint la sortie.
@export var lives_cost: int = 1
## Rayon du disque dessiné (taille visible).
@export var radius: float = 10.0
