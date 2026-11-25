class_name SplashFlash
extends Node2D
## Cercle bref qui montre la zone touchée par un tir de zone.

const DURATION := 0.25

var radius: float = 40.0
var color: Color = Color.WHITE

var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	if _time >= DURATION:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var a := 1.0 - _time / DURATION
	draw_circle(Vector2.ZERO, radius, Color(color, 0.25 * a))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(color, 0.8 * a), 2.0)
