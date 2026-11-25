class_name Projectile
extends Node2D
## Projectile à tête chercheuse. À l'impact : dégâts (de zone si la tour en a), ralentissement, poison.

var _tower_data: TowerData
var _rules: GameRules
var _damage: float
var _poison: float
var _target: Enemy
var _last_target_pos: Vector2


func setup(tower: Tower, target: Enemy) -> void:
	_tower_data = tower.data
	_rules = tower.rules
	_damage = tower.damage()
	_poison = tower.poison_dps()
	_target = target
	_last_target_pos = target.global_position


func _process(delta: float) -> void:
	if is_instance_valid(_target) and _target.is_alive():
		_last_target_pos = _target.global_position
	else:
		_target = null
	var step := _tower_data.projectile_speed * delta
	if global_position.distance_to(_last_target_pos) <= step:
		global_position = _last_target_pos
		_impact()
		queue_free()
	else:
		global_position = global_position.move_toward(_last_target_pos, step)


func _draw() -> void:
	var col := Element.color(_tower_data.element)
	draw_circle(Vector2.ZERO, 4.0 if _tower_data.splash_radius <= 0.0 else 6.0, col)


func _impact() -> void:
	if _tower_data.splash_radius > 0.0:
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy != null and enemy.is_alive() and enemy.global_position.distance_to(global_position) <= _tower_data.splash_radius:
				_hit(enemy)
		_spawn_flash()
	elif _target != null:
		_hit(_target)


func _hit(enemy: Enemy) -> void:
	var mult := _rules.element_multiplier(_tower_data.element, enemy.element)
	if _tower_data.slow_factor < 1.0:
		enemy.apply_slow(_tower_data.slow_factor, _tower_data.slow_duration)
	if _poison > 0.0:
		enemy.apply_poison(_poison * mult, _tower_data.poison_duration)
	enemy.take_damage(_damage * mult)


func _spawn_flash() -> void:
	var flash := SplashFlash.new()
	flash.radius = _tower_data.splash_radius
	flash.color = Element.color(_tower_data.element)
	get_parent().add_child(flash)
	flash.global_position = global_position
