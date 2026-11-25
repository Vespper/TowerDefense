class_name BuilderData
extends Resource
## Le bâtisseur : le personnage qui se déplace et construit les tours (façon builder des TD Warcraft 3).

@export var display_name: String = "Bâtisseur"
## Vitesse de déplacement en pixels par seconde (une case = 40 px).
@export var speed: float = 220.0
## Multiplicateur de vitesse de construction (2 = construit deux fois plus vite).
@export var build_speed: float = 1.0
## Distance au centre de la case à partir de laquelle il peut construire.
@export var build_reach: float = 34.0
