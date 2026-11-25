class_name Board
extends Node2D
## Terrain en grille où l'on construit le labyrinthe. Les tours bloquent leur case ;
## les ennemis prennent le plus court chemin de l'entrée à la sortie (AStarGrid2D, sans diagonale).
## Une tour ne peut jamais fermer complètement le passage.

signal path_changed

@export var columns: int = 24
@export var rows: int = 15
@export var cell_size: int = 40
@export var spawn_cell: Vector2i = Vector2i(0, 7)
@export var exit_cell: Vector2i = Vector2i(23, 7)

var _astar := AStarGrid2D.new()
var _main_path: PackedVector2Array = PackedVector2Array()
var _ghost_cell: Vector2i = Vector2i(-1, -1)
var _ghost_valid: bool = false
var _ghost_range: float = 0.0


func _ready() -> void:
	_astar.region = Rect2i(0, 0, columns, rows)
	_astar.cell_size = Vector2(cell_size, cell_size)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar.update()
	_refresh_main_path()


func _draw() -> void:
	var size := Vector2(columns, rows) * cell_size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.11, 0.11, 0.14))
	var line_color := Color(1, 1, 1, 0.05)
	for x in range(columns + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, size.y), line_color)
	for y in range(rows + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(size.x, y * cell_size), line_color)
	draw_rect(_cell_rect(spawn_cell), Color(0.3, 0.8, 0.4, 0.35))
	draw_rect(_cell_rect(exit_cell), Color(0.9, 0.3, 0.3, 0.45))
	# Chemin actuel des ennemis, en pointillés discrets
	if _main_path.size() > 1:
		var local := PackedVector2Array()
		for p in _main_path:
			local.append(to_local(p))
		draw_polyline(local, Color(1, 0.85, 0.4, 0.18), 3.0)
	if is_inside(_ghost_cell):
		var c := Color(0.3, 1, 0.4, 0.35) if _ghost_valid else Color(1, 0.3, 0.3, 0.35)
		draw_rect(_cell_rect(_ghost_cell), c)
		if _ghost_range > 0.0:
			draw_arc(_cell_center_local(_ghost_cell), _ghost_range, 0, TAU, 48, Color(1, 1, 1, 0.3), 1.5)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < columns and cell.y < rows


func is_blocked(cell: Vector2i) -> bool:
	return is_inside(cell) and _astar.is_point_solid(cell)


func world_to_cell(world: Vector2) -> Vector2i:
	var local := to_local(world)
	return Vector2i(floori(local.x / cell_size), floori(local.y / cell_size))


func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(_cell_center_local(cell))


## Vrai si on peut poser une tour sur cette case : libre, ni entrée ni sortie, aucun ennemi dessus,
## et le passage reste ouvert depuis l'entrée et depuis chaque ennemi présent.
func can_build(cell: Vector2i, enemy_positions: Array[Vector2] = []) -> bool:
	if not is_inside(cell) or cell == spawn_cell or cell == exit_cell or is_blocked(cell):
		return false
	var center := cell_to_world(cell)
	for pos in enemy_positions:
		if pos.distance_to(center) < cell_size:
			return false
	_astar.set_point_solid(cell, true)
	var open := not _astar.get_id_path(spawn_cell, exit_cell).is_empty()
	if open:
		for pos in enemy_positions:
			var from := world_to_cell(pos)
			if is_inside(from) and _astar.get_id_path(from, exit_cell).is_empty():
				open = false
				break
	_astar.set_point_solid(cell, false)
	return open


func set_blocked(cell: Vector2i, blocked: bool) -> void:
	_astar.set_point_solid(cell, blocked)
	_refresh_main_path()
	path_changed.emit()


## Chemin (positions monde) de la case la plus proche de `world` jusqu'au centre de la sortie.
func path_from(world: Vector2) -> PackedVector2Array:
	var from := world_to_cell(world)
	from = Vector2i(clampi(from.x, 0, columns - 1), clampi(from.y, 0, rows - 1))
	var result := PackedVector2Array()
	for cell in _astar.get_id_path(from, exit_cell):
		result.append(cell_to_world(cell))
	return result


## Longueur du chemin entrée → sortie, en cases (mesure du labyrinthe).
func main_path_length() -> int:
	return _main_path.size()


func spawn_position() -> Vector2:
	return cell_to_world(spawn_cell)


func set_ghost(cell: Vector2i, valid: bool, attack_range: float) -> void:
	if cell == _ghost_cell and valid == _ghost_valid and is_equal_approx(attack_range, _ghost_range):
		return
	_ghost_cell = cell
	_ghost_valid = valid
	_ghost_range = attack_range
	queue_redraw()


func clear_ghost() -> void:
	set_ghost(Vector2i(-1, -1), false, 0.0)


func _refresh_main_path() -> void:
	_main_path = path_from(spawn_position())
	queue_redraw()


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell) * cell_size, Vector2(cell_size, cell_size))


func _cell_center_local(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size
