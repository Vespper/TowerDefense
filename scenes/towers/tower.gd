class_name Tower
extends Node2D
## Tour posée sur une case. Vise l'ennemi le plus avancé à portée et tire un projectile.

const PROJECTILE_SCENE := preload("res://scenes/towers/projectile.tscn")

var data: TowerData
var rules: GameRules
var cell: Vector2i
var level: int = 1
## Or dépensé sur cette tour (pose + améliorations), pour la revente.
var total_spent: int = 0
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

var _projectiles_root: Node
var _cooldown: float = 0.0
var _size: float = 32.0


func setup(tower_data: TowerData, game_rules: GameRules, at_cell: Vector2i, cell_size: int, projectiles_root: Node) -> void:
	data = tower_data
	rules = game_rules
	cell = at_cell
	total_spent = tower_data.cost
	_size = cell_size - 6
	_projectiles_root = projectiles_root


func _process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target := _find_target()
	if target == null:
		return
	_cooldown = 1.0 / data.fire_rate
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(self, target)
	_projectiles_root.add_child(projectile)
	projectile.global_position = global_position


func _draw() -> void:
	var col := Element.color(data.element)
	var half := _size / 2.0
	draw_rect(Rect2(-half, -half, _size, _size), Color(0.2, 0.2, 0.25))
	draw_rect(Rect2(-half + 4, -half + 4, _size - 8, _size - 8), col)
	# Un point par niveau
	for i in range(level):
		draw_circle(Vector2(-half + 7 + i * 8, half - 6), 2.5, Color.WHITE)
	if selected:
		draw_rect(Rect2(-half - 2, -half - 2, _size + 4, _size + 4), Color.WHITE, false, 2.0)
		draw_arc(Vector2.ZERO, data.attack_range, 0, TAU, 64, Color(1, 1, 1, 0.35), 1.5)


func damage() -> float:
	return data.damage_at(level)


func poison_dps() -> float:
	return data.poison_at(level)


func can_upgrade() -> bool:
	return level < rules.max_tower_level


func upgrade_cost() -> int:
	return data.upgrade_cost(level)


func upgrade() -> void:
	total_spent += upgrade_cost()
	level += 1
	queue_redraw()


func sell_value() -> int:
	return int(floor(total_spent * rules.sell_refund))


func _find_target() -> Enemy:
	var best: Enemy = null
	var best_left := INF
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		if enemy.global_position.distance_to(global_position) > data.attack_range:
			continue
		var left := enemy.remaining_distance()
		if left < best_left:
			best_left = left
			best = enemy
	return best
