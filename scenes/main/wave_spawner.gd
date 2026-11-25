class_name WaveSpawner
extends Node
## Fait apparaître les ennemis d'une vague, un par un, au rythme de la vague.

signal enemy_spawned(enemy: Enemy)
signal spawning_finished

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")

@export var board: Board
@export var enemies_root: Node

var _wave: WaveData
var _left: int = 0
var _timer: float = 0.0


func start(wave: WaveData) -> void:
	_wave = wave
	_left = wave.count
	_timer = 0.0


func is_spawning() -> bool:
	return _left > 0


func stop() -> void:
	_left = 0


func _process(delta: float) -> void:
	if _left <= 0:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer += _wave.spawn_interval
	_left -= 1
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemies_root.add_child(enemy)
	enemy.setup(_wave.enemy, _wave.element, _wave.health_multiplier, board)
	enemy_spawned.emit(enemy)
	if _left == 0:
		spawning_finished.emit()
