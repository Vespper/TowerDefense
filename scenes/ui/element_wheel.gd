class_name ElementWheel
extends Control
## Roue des six corruptions : chaque flèche va d'une corruption vers celle qu'elle bat (×2).
## Une corruption pas encore débloquée est sombre ; un clic dessus dépense un stigmate pour la débloquer.

signal element_pressed(element: Element.Type)

const SHORT_NAMES := {
	Element.Type.FERVOR: "Fer",
	Element.Type.MADNESS: "Dém",
	Element.Type.ABYSS: "Abî",
	Element.Type.ASH: "Cen",
	Element.Type.ROT: "Pou",
	Element.Type.BONE: "Os",
}
const NODE_RADIUS := 17.0

var _owned: Dictionary = {}
var _can_buy: bool = false
var _hovered: int = -1
var _pulse: float = 0.0


func _ready() -> void:
	# Un texte non vide est nécessaire pour que Godot appelle _get_tooltip
	tooltip_text = " "
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(_can_buy)


## `owned` : éléments débloqués (Element.Type -> true) ; `can_buy` : il reste une essence à dépenser.
func set_state(owned: Dictionary, can_buy: bool) -> void:
	_owned = owned.duplicate()
	_can_buy = can_buy
	set_process(can_buy)
	queue_redraw()


## Un stigmate attend : les corruptions à débloquer pulsent.
func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta * 3.0, TAU)
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	var all := Element.ALL
	# Flèches « bat » (de l'attaquant vers sa victime), sous les ronds
	for i in all.size():
		var from := _node_center(i)
		var to := _node_center((i + 1) % all.size())
		var dir := (to - from).normalized()
		var a := from + dir * (NODE_RADIUS + 2)
		var b := to - dir * (NODE_RADIUS + 3)
		var col := Element.color(all[i])
		draw_line(a, b, col, 2.0, true)
		var side := dir.orthogonal() * 5.0
		draw_colored_polygon(PackedVector2Array([b, b - dir * 9 + side, b - dir * 9 - side]), col)
	for i in all.size():
		var element: Element.Type = all[i]
		var c := _node_center(i)
		var col := Element.color(element)
		var owned := _owned.has(element)
		draw_circle(c, NODE_RADIUS, col if owned else col.darkened(0.65))
		var ring := Color.WHITE if owned else (col if (_can_buy and i == _hovered) else col.darkened(0.2))
		draw_arc(c, NODE_RADIUS, 0, TAU, 32, ring, 2.5 if owned or i == _hovered else 1.5, true)
		if _can_buy and not owned:
			var glow := 0.5 + 0.5 * sin(_pulse)
			draw_arc(c, NODE_RADIUS + 3.0 + glow * 2.0, 0, TAU, 32, Color(col, 0.35 + 0.5 * glow), 2.0, true)
		var text: String = SHORT_NAMES[element]
		var text_col := Color(0.1, 0.1, 0.12) if owned else col
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_string(font, c + Vector2(-w / 2.0, 5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, text_col)
	var legend := "→ ×2"
	var lw := font.get_string_size(legend, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	draw_string(font, size / 2.0 + Vector2(-lw / 2.0, 5), legend, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.75, 0.75, 0.8))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var h := _node_at((event as InputEventMouseMotion).position)
		if h != _hovered:
			_hovered = h
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var i := _node_at((event as InputEventMouseButton).position)
		if i >= 0:
			element_pressed.emit(Element.ALL[i])
			accept_event()


func _get_tooltip(at_position: Vector2) -> String:
	var i := _node_at(at_position)
	if i < 0:
		return "Chaque flèche va vers la corruption battue : dégâts ×2 (et ×0,5 dans l'autre sens)."
	var all := Element.ALL
	var element: Element.Type = all[i]
	var beats: Element.Type = all[(i + 1) % all.size()]
	var feared: Element.Type = all[(i - 1 + all.size()) % all.size()]
	var text := "%s : ×2 contre %s, ×0,5 contre %s" % [
		Element.display_name(element), Element.display_name(beats), Element.display_name(feared)]
	if _owned.has(element):
		text += "\nDébloquée"
	elif _can_buy:
		text += "\nClic : dépenser un stigmate pour la débloquer"
	else:
		text += "\nIl faut un stigmate pour la débloquer"
	return text


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT and _hovered != -1:
		_hovered = -1
		queue_redraw()


func _node_center(i: int) -> Vector2:
	var radius := minf(size.x, size.y) / 2.0 - NODE_RADIUS - 2.0
	var angle := -PI / 2.0 + TAU * i / Element.ALL.size()
	return size / 2.0 + Vector2(cos(angle), sin(angle)) * radius


func _node_at(pos: Vector2) -> int:
	for i in Element.ALL.size():
		if pos.distance_to(_node_center(i)) <= NODE_RADIUS + 2.0:
			return i
	return -1
