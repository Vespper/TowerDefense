class_name Minimap
extends Control
## Minicarte : chemin, ruines, tours et ennemis en petit, avec le cadre de la vue.
## Un clic (ou un glisser) déplace la caméra à cet endroit.

signal view_requested(world_position: Vector2)

var _board: Board
var _camera: Camera2D
var _main: Node
var _scale: float = 1.0
var _offset: Vector2 = Vector2.ZERO
var _timer: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func setup(board: Board, camera: Camera2D, main: Node) -> void:
	_board = board
	_camera = camera
	_main = main
	_fit()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_fit()


## Échelle pour que toute la carte tienne dans le contrôle, centrée.
func _fit() -> void:
	if _board == null or size.x <= 0.0:
		return
	var map_size := Vector2(_board.columns, _board.rows) * _board.cell_size
	_scale = minf(size.x / map_size.x, size.y / map_size.y)
	_offset = (size - map_size * _scale) / 2.0


func _process(delta: float) -> void:
	# Pas besoin de redessiner à chaque image
	_timer -= delta
	if _timer <= 0.0:
		_timer = 0.1
		queue_redraw()


func _to_mini(world: Vector2) -> Vector2:
	return _offset + (world - _board.global_position) * _scale


func _to_world(mini: Vector2) -> Vector2:
	return _board.global_position + (mini - _offset) / _scale


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.08, 0.075))
	if _board == null:
		return
	var cs := _board.cell_size * _scale
	var map_rect := Rect2(_offset, Vector2(_board.columns, _board.rows) * cs)
	draw_rect(map_rect, Color(0.12, 0.13, 0.12))
	for c in _board.path_cells():
		draw_rect(Rect2(_offset + Vector2(c) * cs, Vector2(cs, cs)), Color(0.42, 0.35, 0.26))
	for c in _board.map.corrupted_cells:
		var col := Element.color(_board.map.corrupted_cells[c] as Element.Type)
		draw_rect(Rect2(_offset + Vector2(c) * cs, Vector2(cs, cs)), Color(col, 0.5))
	if _main != null:
		for r in _main.ruins():
			draw_rect(Rect2(_offset + Vector2(r.cell) * cs, Vector2(cs, cs)), Color(0.55, 0.5, 0.45))
		for t in _main.towers():
			draw_rect(Rect2(_offset + Vector2(t.cell) * cs, Vector2(cs, cs)).grow(0.5), Element.color(t.data.element))
		for e in _main.enemies_root.get_children():
			draw_circle(_to_mini((e as Node2D).global_position), maxf(cs * 0.4, 1.5), Color(0.95, 0.3, 0.25))
		draw_circle(_to_mini(_main.builder.global_position), maxf(cs * 0.6, 2.0), Color(0.6, 0.8, 1.0))
	if _camera != null:
		var view := get_viewport_rect().size / _camera.zoom
		var top_left := _camera.get_screen_center_position() - view / 2.0
		draw_rect(Rect2(_to_mini(top_left), view * _scale), Color(1, 1, 1, 0.8), false, 1.0)


func _gui_input(event: InputEvent) -> void:
	if _board == null:
		return
	var press := event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	var drag := event is InputEventMouseMotion and ((event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT) != 0
	if press or drag:
		view_requested.emit(_to_world((event as InputEventMouse).position))
		accept_event()
