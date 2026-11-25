class_name Tower
extends Node2D
## Tour posée sur une case. Elle est d'abord un chantier que le bâtisseur doit construire ;
## une fois construite, elle vise l'ennemi le plus avancé à portée et tire un projectile.

signal built(tower: Tower)

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

## Avancement du chantier, de 0 à 1 (1 = construite).
var build_progress: float = 0.0

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
	if not is_built():
		return
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
	if not is_built():
		# Chantier : contour pointillé de la tour, barre d'avancement
		draw_rect(Rect2(-half, -half, _size, _size), Color(col, 0.25))
		draw_rect(Rect2(-half, -half, _size, _size), Color(col, 0.8), false, 2.0)
		draw_rect(Rect2(-half + 3, half - 8, (_size - 6), 5), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-half + 3, half - 8, (_size - 6) * build_progress, 5), Color(1, 0.85, 0.35))
		if selected:
			draw_rect(Rect2(-half - 2, -half - 2, _size + 4, _size + 4), Color.WHITE, false, 2.0)
		return
	draw_rect(Rect2(-half, -half, _size, _size), Color(0.2, 0.2, 0.25))
	draw_rect(Rect2(-half + 4, -half + 4, _size - 8, _size - 8), col)
	# Les tours de base ont un symbole pour les distinguer (même couleur neutre)
	if data.splash_radius > 0.0 and data.element == Element.Type.NONE:
		draw_circle(Vector2.ZERO, 6.0, Color(0.25, 0.25, 0.3))
	elif data.chain_count > 0 and data.element == Element.Type.NONE:
		draw_line(Vector2(-6, -6), Vector2(2, 0), Color(0.4, 0.3, 0.8), 3.0)
		draw_line(Vector2(2, 0), Vector2(-2, 2), Color(0.4, 0.3, 0.8), 3.0)
		draw_line(Vector2(-2, 2), Vector2(6, 8), Color(0.4, 0.3, 0.8), 3.0)
	# Un point par niveau
	for i in range(level):
		draw_circle(Vector2(-half + 7 + i * 8, half - 6), 2.5, Color.WHITE)
	if selected:
		draw_rect(Rect2(-half - 2, -half - 2, _size + 4, _size + 4), Color.WHITE, false, 2.0)
		draw_arc(Vector2.ZERO, data.attack_range, 0, TAU, 64, Color(1, 1, 1, 0.35), 1.5)


func is_built() -> bool:
	return build_progress >= 1.0


## Fait avancer le chantier (appelé par le bâtisseur). `speed` multiplie la vitesse de construction.
func work(delta: float, speed: float = 1.0) -> void:
	if is_built():
		return
	build_progress = minf(build_progress + delta * speed / maxf(data.build_time, 0.01), 1.0)
	queue_redraw()
	if is_built():
		built.emit(self)


func damage() -> float:
	return data.damage_at(level)


func poison_dps() -> float:
	return data.poison_at(level)


func can_upgrade() -> bool:
	return is_built() and level < rules.max_tower_level


func upgrade_cost() -> int:
	return data.upgrade_cost(level)


func upgrade() -> void:
	total_spent += upgrade_cost()
	level += 1
	queue_redraw()


## Un chantier annulé est remboursé en entier.
func sell_value() -> int:
	if not is_built():
		return total_spent
	return int(floor(total_spent * rules.sell_refund))


func _find_target() -> Enemy:
	var best: Enemy = null
	var best_left := INF
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		if enemy.is_flying() and not data.hits_air:
			continue
		if enemy.global_position.distance_to(global_position) > data.attack_range:
			continue
		var left := enemy.remaining_distance()
		if left < best_left:
			best_left = left
			best = enemy
	return best
