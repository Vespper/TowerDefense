class_name Board
extends Node2D
## Terrain en grille avec un chemin fixe (MapData). Les tours se posent sur toutes les cases hors du chemin
## et hors des ruines. Certaines cases sont des terres corrompues (bonus ou malus selon la tour).

@export var map: MapData
@export var cell_size: int = 40

var columns: int = 0
var rows: int = 0

var _path_cells: Array[Vector2i] = []
var _path_lookup: Dictionary = {}
var _path_points: PackedVector2Array = PackedVector2Array()
var _occupied: Dictionary = {}
var _ghost_cell: Vector2i = Vector2i(-1, -1)
var _ghost_valid: bool = false
var _ghost_range: float = 0.0
## Multiplicateur de la terre sous la tour fantôme (1 = sans effet).
var _ghost_terrain: float = 1.0
var _blocked: Dictionary = {}


func _ready() -> void:
	columns = map.columns
	rows = map.rows
	_path_cells = map.path_cells()
	for c in _path_cells:
		_path_lookup[c] = true
	# Les ennemis entrent et sortent par le bord de la carte, pas au milieu de la première case
	_path_points.append(_edge_point(_path_cells[0], _path_cells[1]))
	for w in map.waypoints:
		_path_points.append(cell_to_world(w))
	_path_points.append(_edge_point(_path_cells[-1], _path_cells[-2]))


func _draw() -> void:
	var size := Vector2(columns, rows) * cell_size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.13, 0.15, 0.13))
	var line_color := Color(1, 1, 1, 0.04)
	for x in range(columns + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, size.y), line_color)
	for y in range(rows + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(size.x, y * cell_size), line_color)
	for c in _path_cells:
		draw_rect(_cell_rect(c), Color(0.36, 0.3, 0.22))
	for c in map.corrupted_cells:
		_draw_corrupted(c, map.corrupted_cells[c])
	draw_rect(_cell_rect(_path_cells[0]), Color(0.3, 0.8, 0.4, 0.35))
	draw_rect(_cell_rect(_path_cells[-1]), Color(0.9, 0.3, 0.3, 0.45))
	if is_inside(_ghost_cell):
		var c := Color(0.3, 1, 0.4, 0.35) if _ghost_valid else Color(1, 0.3, 0.3, 0.35)
		draw_rect(_cell_rect(_ghost_cell), c)
		if _ghost_range > 0.0:
			draw_arc(_cell_center_local(_ghost_cell), _ghost_range, 0, TAU, 48, Color(1, 1, 1, 0.3), 1.5)
		if not is_equal_approx(_ghost_terrain, 1.0):
			var font := ThemeDB.fallback_font
			var text := "%+d %%" % roundi((_ghost_terrain - 1.0) * 100.0)
			var col := Color(0.5, 1, 0.5) if _ghost_terrain > 1.0 else Color(1, 0.45, 0.4)
			draw_string(font, Vector2(_ghost_cell) * cell_size + Vector2(-6, -4), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < columns and cell.y < rows


func is_path(cell: Vector2i) -> bool:
	return _path_lookup.has(cell)


func is_occupied(cell: Vector2i) -> bool:
	return _occupied.has(cell)


## Vrai si on peut poser une tour ici : dans la carte, hors du chemin, case libre (ni tour ni ruine).
func can_build(cell: Vector2i) -> bool:
	return is_inside(cell) and not is_path(cell) and not is_occupied(cell) and not is_blocked(cell)


## Corruption de la terre de cette case (NONE si case normale).
func terrain_at(cell: Vector2i) -> Element.Type:
	return map.corrupted_cells.get(cell, Element.Type.NONE) as Element.Type


## Case bloquée par une ruine.
func is_blocked(cell: Vector2i) -> bool:
	return _blocked.has(cell)


func set_blocked(cell: Vector2i, blocked: bool) -> void:
	if blocked:
		_blocked[cell] = true
	else:
		_blocked.erase(cell)
	queue_redraw()


func set_occupied(cell: Vector2i, occupied: bool) -> void:
	if occupied:
		_occupied[cell] = true
	else:
		_occupied.erase(cell)


func world_to_cell(world: Vector2) -> Vector2i:
	var local := to_local(world)
	return Vector2i(floori(local.x / cell_size), floori(local.y / cell_size))


func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(_cell_center_local(cell))


## Points (monde) que suivent les ennemis, de l'entrée à la sortie.
func path_points() -> PackedVector2Array:
	return _path_points


func path_cells() -> Array[Vector2i]:
	return _path_cells


## `terrain_mult` : multiplicateur de la terre sous la tour fantôme, affiché s'il change quelque chose.
func set_ghost(cell: Vector2i, valid: bool, attack_range: float, terrain_mult: float = 1.0) -> void:
	if cell == _ghost_cell and valid == _ghost_valid and is_equal_approx(attack_range, _ghost_range) and is_equal_approx(terrain_mult, _ghost_terrain):
		return
	_ghost_cell = cell
	_ghost_valid = valid
	_ghost_range = attack_range
	_ghost_terrain = terrain_mult
	queue_redraw()


func clear_ghost() -> void:
	set_ghost(Vector2i(-1, -1), false, 0.0)


## Point sur le bord de la case `cell`, du côté opposé à `neighbor`.
func _edge_point(cell: Vector2i, neighbor: Vector2i) -> Vector2:
	var away := Vector2(cell - neighbor)
	return cell_to_world(cell) + away * cell_size * 0.5


## Terre corrompue : fond teinté de la couleur de la corruption, liseré et motif en croix.
func _draw_corrupted(cell: Vector2i, element: int) -> void:
	var col := Element.color(element as Element.Type)
	var r := _cell_rect(cell)
	draw_rect(r, Color(col, 0.16))
	draw_rect(r.grow(-2), Color(col, 0.45), false, 1.5)
	var c := r.get_center()
	draw_line(c + Vector2(-5, -5), c + Vector2(5, 5), Color(col, 0.35), 1.5)
	draw_line(c + Vector2(-5, 5), c + Vector2(5, -5), Color(col, 0.35), 1.5)


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))


func _cell_center_local(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size
