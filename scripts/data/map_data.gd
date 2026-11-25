class_name MapData
extends Resource
## Une carte : taille de la grille et chemin fixe des ennemis, donné par ses coins.
## Le chemin va d'un coin au suivant en ligne droite (horizontale ou verticale).
## Toutes les cases hors du chemin sont constructibles.

@export var display_name: String = "Carte"
@export var columns: int = 24
@export var rows: int = 15
## Coins du chemin, de l'entrée à la sortie. Deux coins qui se suivent sont sur la même ligne ou colonne.
@export var waypoints: Array[Vector2i] = []


## Toutes les cases du chemin, dans l'ordre.
func path_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i in range(waypoints.size() - 1):
		var a := waypoints[i]
		var b := waypoints[i + 1]
		var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
		var c := a
		while c != b:
			if cells.is_empty() or cells[-1] != c:
				cells.append(c)
			c += step
	if not waypoints.is_empty():
		cells.append(waypoints[-1])
	return cells
