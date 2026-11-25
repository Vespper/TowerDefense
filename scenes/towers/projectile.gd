class_name Projectile
extends Node2D
## Projectile à tête chercheuse. À l'impact : dégâts (de zone ou en rebonds si la tour en a),
## ralentissement, poison. La zone ne touche pas les volants.

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
		# La cible est toujours touchée (même volante) ; la zone autour ne touche que le sol
		if _target != null:
			_hit(_target)
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy != null and enemy != _target and enemy.is_alive() and not enemy.is_flying() \
					and enemy.global_position.distance_to(global_position) <= _tower_data.splash_radius:
				_hit(enemy)
		_spawn_flash()
	elif _target != null:
		_hit(_target)
		if _tower_data.chain_count > 0:
			_chain(_target)


## Rebondit vers l'ennemi le plus proche pas encore touché, chaque fois que possible.
func _chain(first: Enemy) -> void:
	var touched: Array[Enemy] = [first]
	var from := first.global_position
	var points := PackedVector2Array([from])
	for i in _tower_data.chain_count:
		var next: Enemy = null
		var best := _tower_data.chain_range
		for node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy == null or not enemy.is_alive() or touched.has(enemy):
				continue
			if enemy.is_flying() and not _tower_data.hits_air:
				continue
			var d := enemy.global_position.distance_to(from)
			if d <= best:
				best = d
				next = enemy
		if next == null:
			break
		touched.append(next)
		from = next.global_position
		points.append(from)
		_hit(next)
	if points.size() > 1:
		var bolt := ChainBolt.new()
		bolt.points = points
		bolt.color = Element.color(_tower_data.element).lerp(Color(0.6, 0.5, 1.0), 0.6)
		get_parent().add_child(bolt)


func _hit(enemy: Enemy) -> void:
	var mult := _rules.damage_multiplier(_tower_data, enemy.element, enemy.armor)
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
