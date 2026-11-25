class_name Enemy
extends Node2D
## Ennemi qui suit le chemin du labyrinthe jusqu'à la sortie. Recalcule son chemin quand une tour est posée.

signal died(enemy: Enemy)
signal reached_exit(enemy: Enemy)

var data: EnemyData
var element: Element.Type = Element.Type.NONE
var max_health: float = 1.0
var health: float = 1.0

var _board: Board
var _path: PackedVector2Array = PackedVector2Array()
var _index: int = 0
## Longueur restante après chaque point du chemin (pour savoir qui est le plus avancé).
var _remaining_after: PackedFloat32Array = PackedFloat32Array()
var _slow_factor: float = 1.0
var _slow_time: float = 0.0
var _poison_dps: float = 0.0
var _poison_time: float = 0.0
var _dead: bool = false


func setup(enemy_data: EnemyData, wave_element: Element.Type, health_multiplier: float, board: Board) -> void:
	data = enemy_data
	element = wave_element
	max_health = enemy_data.max_health * health_multiplier
	health = max_health
	_board = board
	global_position = board.spawn_position()
	board.path_changed.connect(_repath)
	_repath()


func _process(delta: float) -> void:
	if _dead:
		return
	_update_effects(delta)
	if _dead:
		return
	var step := data.speed * _slow_factor * delta
	while step > 0.0 and _index < _path.size():
		var target := _path[_index]
		var dist := global_position.distance_to(target)
		if dist <= step:
			global_position = target
			step -= dist
			_index += 1
		else:
			global_position = global_position.move_toward(target, step)
			step = 0.0
	if _index >= _path.size():
		_dead = true
		reached_exit.emit(self)
		queue_free()
	queue_redraw()


func _draw() -> void:
	var col := Element.color(element)
	draw_circle(Vector2.ZERO, data.radius, col)
	draw_arc(Vector2.ZERO, data.radius, 0, TAU, 24, col.darkened(0.6), 2.0)
	if _slow_time > 0.0:
		draw_arc(Vector2.ZERO, data.radius + 3, 0, TAU, 24, Color(0.6, 0.85, 1.0, 0.9), 2.0)
	if _poison_time > 0.0:
		draw_circle(Vector2(data.radius * 0.6, -data.radius * 0.6), 3.0, Color(0.5, 1.0, 0.3))
	# Barre de vie
	var w := data.radius * 2.0
	var top := Vector2(-data.radius, -data.radius - 7)
	draw_rect(Rect2(top, Vector2(w, 3)), Color(0.5, 0.1, 0.1, 0.8))
	draw_rect(Rect2(top, Vector2(w * health / max_health, 3)), Color(0.95, 0.95, 0.95))


func is_alive() -> bool:
	return not _dead


## Distance qu'il reste à parcourir jusqu'à la sortie (plus petit = plus dangereux).
func remaining_distance() -> float:
	if _index >= _path.size():
		return 0.0
	return global_position.distance_to(_path[_index]) + _remaining_after[_index]


func take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0.0:
		_dead = true
		died.emit(self)
		queue_free()
	else:
		queue_redraw()


## Garde le ralentissement le plus fort ; la durée repart.
func apply_slow(factor: float, duration: float) -> void:
	if factor < _slow_factor or _slow_time <= 0.0:
		_slow_factor = factor
	_slow_time = maxf(_slow_time, duration)


## Garde le poison le plus fort ; la durée repart.
func apply_poison(dps: float, duration: float) -> void:
	_poison_dps = maxf(_poison_dps if _poison_time > 0.0 else 0.0, dps)
	_poison_time = maxf(_poison_time, duration)


func _update_effects(delta: float) -> void:
	if _slow_time > 0.0:
		_slow_time -= delta
		if _slow_time <= 0.0:
			_slow_factor = 1.0
	if _poison_time > 0.0:
		var tick := minf(delta, _poison_time)
		_poison_time -= delta
		take_damage(_poison_dps * tick)


func _repath() -> void:
	_path = _board.path_from(global_position)
	_index = 0
	_remaining_after.resize(_path.size())
	var acc := 0.0
	for i in range(_path.size() - 1, -1, -1):
		_remaining_after[i] = acc
		if i > 0:
			acc += _path[i].distance_to(_path[i - 1])
