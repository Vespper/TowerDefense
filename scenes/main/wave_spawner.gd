class_name WaveSpawner
extends Node
## Fait apparaître les ennemis d'une vague, un par un, au rythme de la vague.
## Les élites sont réparties régulièrement dans le groupe.

signal enemy_spawned(enemy: Enemy)
signal spawning_finished

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")

@export var board: Board
@export var enemies_root: Node

var _wave: WaveData
## File d'apparition : true = élite, false = ennemi normal.
var _queue: Array[bool] = []
var _timer: float = 0.0
var _elite_element: Element.Type = Element.Type.NONE


## `elite_element` : corruption des élites de cette vague (choisie par le joueur ou tirée au hasard).
func start(wave: WaveData, elite_element: Element.Type = Element.Type.NONE) -> void:
	_wave = wave
	_elite_element = elite_element if elite_element != Element.Type.NONE else wave.elite_element
	_timer = 0.0
	_queue.clear()
	var elites := wave.elite_count if wave.elite != null else 0
	var total := wave.count + elites
	for i in total:
		_queue.append(false)
	# Élites placées à intervalles réguliers (jamais en tête)
	for k in elites:
		var at := int(round(float(k + 1) * total / float(elites + 1)))
		_queue[clampi(at, 1, total - 1) if total > 1 else 0] = true
	# Si deux élites tombent sur la même place, compléter
	var placed := _queue.count(true)
	var i := total - 1
	while placed < elites and i >= 0:
		if not _queue[i]:
			_queue[i] = true
			placed += 1
		i -= 1


func is_spawning() -> bool:
	return not _queue.is_empty()


func stop() -> void:
	_queue.clear()


func _process(delta: float) -> void:
	if _queue.is_empty():
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer += _wave.spawn_interval
	var is_elite: bool = _queue.pop_front()
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	enemies_root.add_child(enemy)
	if is_elite:
		enemy.setup(_wave.elite, _elite_element, _wave.health_multiplier, board)
		enemy.set_meta("elite", true)
	else:
		enemy.setup(_wave.enemy, _wave.element, _wave.health_multiplier, board, _wave.armor)
	enemy_spawned.emit(enemy)
	if _queue.is_empty():
		spawning_finished.emit()
