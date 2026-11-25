class_name EnemyData
extends Resource
## Un archétype d'ennemi. Son élément vient de la vague (WaveData).

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
## Volant : seules les tours qui touchent l'air peuvent le viser, la zone ne l'atteint pas.
@export var flying: bool = false
## En mourant, soigne les ennemis proches de cette part de leurs PV max (0 = rien).
@export_range(0.0, 1.0) var heal_on_death: float = 0.0
@export var heal_radius: float = 100.0
## Élite : dessinée plus grande, avec une couronne.
@export var elite: bool = false
