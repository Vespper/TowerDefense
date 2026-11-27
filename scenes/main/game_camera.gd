class_name GameCamera
extends Camera2D
## Caméra de la partie. Elle suit le bâtisseur ; clic molette glissé pour regarder ailleurs,
## molette pour zoomer, C pour revenir sur le bâtisseur. Dès que le bâtisseur bouge, elle le suit de nouveau.
## Elle marche aussi pendant la pause, pour lire la carte.

const ZOOM_MIN := 0.6
const ZOOM_MAX := 1.5
const ZOOM_STEP := 0.1
## Vitesse de rattrapage du bâtisseur (plus grand = plus sec).
const FOLLOW_SPEED := 6.0

## Le nœud suivi (le bâtisseur).
var target: Node2D
## Vrai tant que la caméra suit le bâtisseur.
var following: bool = true

var _dragging: bool = false
var _last_target_pos: Vector2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if target:
		global_position = target.global_position
		_last_target_pos = target.global_position


## Limites de la caméra : la carte, avec une marge pour l'interface autour.
func set_bounds(rect: Rect2, margin_left: float, margin_top: float, margin_right: float, margin_bottom: float) -> void:
	limit_left = int(rect.position.x - margin_left)
	limit_top = int(rect.position.y - margin_top)
	limit_right = int(rect.end.x + margin_right)
	limit_bottom = int(rect.end.y + margin_bottom)


func _process(delta: float) -> void:
	if target == null:
		return
	if target.global_position.distance_to(_last_target_pos) > 0.5:
		# Le bâtisseur bouge : on le suit de nouveau
		following = true
		_last_target_pos = target.global_position
	if following and not _dragging:
		# Utiliser le temps réel : la caméra suit aussi en pause et à vitesse ×3
		var real_delta := delta / maxf(Engine.time_scale, 0.01)
		global_position = global_position.lerp(target.global_position, clampf(real_delta * FOLLOW_SPEED, 0.0, 1.0))
	_clamp_to_limits()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = mb.pressed
			if mb.pressed:
				following = false
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_zoom_level(zoom.x + ZOOM_STEP)
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_zoom_level(zoom.x - ZOOM_STEP)
	elif event is InputEventMouseMotion and _dragging:
		global_position -= (event as InputEventMouseMotion).relative / zoom
	elif event.is_action_pressed("center_camera"):
		following = true


func set_zoom_level(level: float) -> void:
	var z := clampf(level, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(z, z)


## Garde le centre de la caméra dans ses limites (Camera2D ne limite que l'affichage, pas sa position).
func _clamp_to_limits() -> void:
	var half := get_viewport_rect().size / zoom / 2.0
	var min_pos := Vector2(limit_left, limit_top) + half
	var max_pos := Vector2(limit_right, limit_bottom) - half
	if min_pos.x > max_pos.x:
		min_pos.x = (limit_left + limit_right) / 2.0
		max_pos.x = min_pos.x
	if min_pos.y > max_pos.y:
		min_pos.y = (limit_top + limit_bottom) / 2.0
		max_pos.y = min_pos.y
	global_position = global_position.clamp(min_pos, max_pos)
