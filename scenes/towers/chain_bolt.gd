class_name ChainBolt
extends Node2D
## Éclair bref entre les ennemis touchés par un rebond.

const DURATION := 0.2

## Points en coordonnées monde (le nœud reste à l'origine).
var points: PackedVector2Array = PackedVector2Array()
var color: Color = Color.WHITE

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var a := 1.0 - _time / DURATION
	var local := PackedVector2Array()
	for p in points:
		local.append(to_local(p))
	draw_polyline(local, Color(color, a), 2.5)
