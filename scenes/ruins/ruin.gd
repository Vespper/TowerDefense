class_name Ruin
extends Worksite
## Ruine qui bloque une case constructible. On paie pour que le bâtisseur la démolisse ;
## une fois démolie, la case est libre. Les ruines sont placées sur de bonnes cases (MapData.ruins).

signal cleared(ruin: Ruin)

var cell: Vector2i
## Démolition commandée (or payé) et pas encore finie.
var ordered: bool = false
## Avancement de la démolition, de 0 à 1.
var progress: float = 0.0
var _duration: float = 4.0
var _size: float = 32.0


func setup(at_cell: Vector2i, cell_size: int, duration: float) -> void:
	cell = at_cell
	_size = cell_size - 4
	_duration = duration


func work(delta: float, speed: float = 1.0) -> void:
	if is_built():
		return
	progress = minf(progress + delta * speed / maxf(_duration, 0.01), 1.0)
	queue_redraw()
	if is_built():
		cleared.emit(self)


func is_built() -> bool:
	return progress >= 1.0


func set_ordered(value: bool) -> void:
	ordered = value
	if not ordered:
		progress = 0.0
	queue_redraw()


func _draw() -> void:
	var half := _size / 2.0
	# Tas de pierres et d'os, de plus en plus bas pendant la démolition
	draw_rect(Rect2(-half, -half, _size, _size), Color(0.17, 0.15, 0.14, 0.9 * (1.0 - progress)))
	var h := 1.0 - progress * 0.7
	var stone := Color(0.42, 0.39, 0.36)
	var dark := Color(0.28, 0.26, 0.25)
	draw_rect(Rect2(-half, half - 10 * h, _size, 10 * h), dark)
	draw_rect(Rect2(-half + 3, half - 22 * h, 12, 14 * h), stone)
	draw_rect(Rect2(-1, half - 28 * h, 12, 20 * h), stone)
	draw_rect(Rect2(half - 9, half - 16 * h, 7, 8 * h), stone)
	# Un os en travers
	var bone := Color(0.86, 0.82, 0.7)
	draw_line(Vector2(-half + 4, half - 4), Vector2(half - 8, half - 12 * h), bone, 3.0)
	draw_circle(Vector2(-half + 4, half - 4), 3, bone)
	draw_circle(Vector2(half - 8, half - 12 * h), 3, bone)
	if ordered:
		draw_rect(Rect2(-half, -half, _size, _size), Color(1, 0.85, 0.35, 0.8), false, 2.0)
		draw_rect(Rect2(-half, -half - 6, _size, 4), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-half, -half - 6, _size * progress, 4), Color(1, 0.85, 0.35))
