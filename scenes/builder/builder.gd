class_name Builder
extends Node2D
## Le bâtisseur. Se déplace au clavier (ZQSD / WASD / flèches) ; les tours commandées et les ruines à démolir
## forment une file de chantiers (Worksite) : il marche jusqu'au premier, le termine, puis passe au suivant.
## Il marche partout (chemin compris) et ne peut pas être blessé.

signal queue_changed

@export var data: BuilderData
## Zone où il peut marcher (coordonnées monde). Réglée par Main d'après le terrain.
var bounds: Rect2 = Rect2(0, 0, 1280, 720)

var _queue: Array[Worksite] = []
var _facing: Vector2 = Vector2.RIGHT
var _working: bool = false
var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	_clean_queue()
	var manual := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_working = false
	if manual != Vector2.ZERO:
		_move(manual * data.speed * delta)
	elif not _queue.is_empty():
		var site := _queue[0]
		var to_site := site.global_position - global_position
		if to_site.length() > data.build_reach:
			_move(to_site.limit_length(data.speed * delta))
		else:
			_working = true
			site.work(delta, data.build_speed)
			if site.is_built():
				_queue.pop_front()
				queue_changed.emit()
	queue_redraw()


func _draw() -> void:
	# Trajet vers les chantiers en attente
	var from := Vector2.ZERO
	for site in _queue:
		if is_instance_valid(site):
			var to := to_local(site.global_position)
			draw_dashed_line(from, to, Color(1, 0.85, 0.35, 0.35), 2.0, 6.0)
			from = to
	draw_circle(Vector2(0, 9), 9, Color(0, 0, 0, 0.35))
	# Blanc cerclé de bleu : ne se confond avec aucun élément
	draw_circle(Vector2.ZERO, 11, Color(0.92, 0.96, 1.0))
	draw_arc(Vector2.ZERO, 11, 0, TAU, 24, Color(0.15, 0.35, 0.85), 3.0)
	draw_line(Vector2.ZERO, _facing * 15, Color(0.15, 0.35, 0.85), 3.0)
	if _working:
		# Marteau qui tape
		var angle := sin(_time * 18.0) * 0.8
		var tip := _facing.rotated(angle) * 20
		draw_line(_facing * 8, tip, Color(0.5, 0.35, 0.2), 3.0)
		draw_circle(tip, 4, Color(0.7, 0.7, 0.75))


## Ajoute un chantier à la file.
func order(site: Worksite) -> void:
	_queue.append(site)
	queue_changed.emit()


## Retire un chantier de la file (démolition annulée).
func cancel(site: Worksite) -> void:
	if _queue.has(site):
		_queue.erase(site)
		queue_changed.emit()


func pending_orders() -> int:
	_clean_queue()
	return _queue.size()


func is_working() -> bool:
	return _working


func _move(step: Vector2) -> void:
	if step != Vector2.ZERO:
		_facing = step.normalized()
	global_position = (global_position + step).clamp(bounds.position, bounds.end)


## Retire les chantiers vendus ou terminés.
func _clean_queue() -> void:
	var kept: Array[Worksite] = []
	for t in _queue:
		if is_instance_valid(t) and not t.is_queued_for_deletion() and not t.is_built():
			kept.append(t)
	if kept.size() != _queue.size():
		_queue = kept
		queue_changed.emit()
