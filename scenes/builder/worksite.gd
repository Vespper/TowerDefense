class_name Worksite
extends Node2D
## Ce que le bâtisseur peut travailler : un chantier de tour (Tower) ou une ruine à démolir (Ruin).
## Il marche jusqu'au chantier et appelle `work` jusqu'à ce que `is_built` soit vrai.


## Fait avancer le chantier. `speed` multiplie la vitesse du bâtisseur.
func work(_delta: float, _speed: float = 1.0) -> void:
	pass


## Vrai quand il n'y a plus rien à faire ici.
func is_built() -> bool:
	return true
