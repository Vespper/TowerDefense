class_name Tower
extends Worksite
## Tour posée sur une case. Elle est d'abord un chantier que le bâtisseur doit construire ;
## une fois construite, elle vise l'ennemi le plus avancé à portée et tire un projectile.
## Une amélioration est aussi un chantier : la tour est hors service jusqu'à ce que le bâtisseur l'ait finie.

signal built(tower: Tower)

const PROJECTILE_SCENE := preload("res://scenes/towers/projectile.tscn")

var data: TowerData
var rules: GameRules
var cell: Vector2i
var level: int = 1
## Corruption de la terre sous la tour (NONE si case normale).
var terrain: Element.Type = Element.Type.NONE
## Bonus de dégâts des stigmates d'élite de sa corruption (1 = aucun).
var corruption_boost: float = 1.0
## Branche d'amélioration choisie au niveau 2 (-1 = pas encore choisie).
var branch: int = -1
## Or dépensé sur cette tour (pose + améliorations), pour la revente.
var total_spent: int = 0
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()

## Avancement du chantier (construction ou amélioration), de 0 à 1 (1 = terminé).
var build_progress: float = 0.0

## Or payé pour le chantier en cours, rendu en entier si on vend avant la fin.
var _pending_cost: int = 0
var _projectiles_root: Node
var _cooldown: float = 0.0
var _size: float = 32.0


func setup(tower_data: TowerData, game_rules: GameRules, at_cell: Vector2i, cell_size: int, projectiles_root: Node) -> void:
	data = tower_data
	rules = game_rules
	cell = at_cell
	total_spent = tower_data.cost
	_pending_cost = tower_data.cost
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
	_cooldown = 1.0 / fire_rate()
	var projectile: Projectile = PROJECTILE_SCENE.instantiate()
	projectile.setup(self, target)
	_projectiles_root.add_child(projectile)
	projectile.global_position = global_position


func _draw() -> void:
	var col := Element.color(data.element)
	var half := _size / 2.0
	if not is_built() and not is_upgrading():
		# Chantier de construction : contour de la tour et barre d'avancement
		draw_rect(Rect2(-half, -half, _size, _size), Color(col, 0.25))
		draw_rect(Rect2(-half, -half, _size, _size), Color(col, 0.8), false, 2.0)
		_draw_progress(half)
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
	if is_upgrading():
		# Amélioration en cours : tour assombrie (hors service), flèche vers le haut, barre d'avancement
		draw_rect(Rect2(-half, -half, _size, _size), Color(0, 0, 0, 0.55))
		draw_colored_polygon(PackedVector2Array([Vector2(0, -10), Vector2(8, 0), Vector2(-8, 0)]), Color(1, 0.85, 0.35))
		draw_rect(Rect2(-3, 0, 6, 7), Color(1, 0.85, 0.35))
		_draw_progress(half)
	if selected:
		draw_rect(Rect2(-half - 2, -half - 2, _size + 4, _size + 4), Color.WHITE, false, 2.0)
		draw_arc(Vector2.ZERO, attack_range(), 0, TAU, 64, Color(1, 1, 1, 0.35), 1.5)


func is_built() -> bool:
	return build_progress >= 1.0


## Vrai pendant une amélioration (la tour ne tire pas).
func is_upgrading() -> bool:
	return not is_built() and level > 1


## Durée du chantier en cours : temps de construction × niveau visé.
func work_duration() -> float:
	return data.build_time * level


## Fait avancer le chantier (appelé par le bâtisseur). `speed` multiplie la vitesse de construction.
func work(delta: float, speed: float = 1.0) -> void:
	if is_built():
		return
	build_progress = minf(build_progress + delta * speed / maxf(work_duration(), 0.01), 1.0)
	queue_redraw()
	if is_built():
		_pending_cost = 0
		built.emit(self)


## Branche choisie, ou null.
func chosen_branch() -> TowerBranch:
	if branch < 0 or branch >= data.branches.size():
		return null
	return data.branches[branch]


## Nombre de fois que les bonus de la branche s'appliquent (niveau - 1).
func _branch_steps() -> int:
	return level - 1 if chosen_branch() != null else 0


## Multiplicateur de la terre corrompue sous la tour (1 si sans effet).
func terrain_multiplier() -> float:
	return rules.terrain_multiplier(data.element, terrain) * corruption_boost


func damage() -> float:
	var b := chosen_branch()
	return data.damage * (pow(b.damage_mult, _branch_steps()) if b else 1.0) * terrain_multiplier()


func fire_rate() -> float:
	var b := chosen_branch()
	return data.fire_rate * (pow(b.fire_rate_mult, _branch_steps()) if b else 1.0)


func attack_range() -> float:
	var b := chosen_branch()
	return data.attack_range * (pow(b.range_mult, _branch_steps()) if b else 1.0)


func poison_dps() -> float:
	var b := chosen_branch()
	return data.poison_dps * (pow(b.poison_mult, _branch_steps()) if b else 1.0) * terrain_multiplier()


func splash_radius() -> float:
	if data.splash_radius <= 0.0:
		return 0.0
	var b := chosen_branch()
	return data.splash_radius + (b.splash_bonus * _branch_steps() if b else 0.0)


func chain_count() -> int:
	var b := chosen_branch()
	return data.chain_count + (b.chain_bonus * _branch_steps() if b else 0)


func slow_factor() -> float:
	if data.slow_factor >= 1.0:
		return 1.0
	var b := chosen_branch()
	return maxf(data.slow_factor - (b.slow_bonus * _branch_steps() if b else 0.0), 0.1)


func can_upgrade() -> bool:
	return is_built() and level < rules.max_tower_level


## Vrai si la prochaine amélioration demande de choisir une branche.
func needs_branch_choice() -> bool:
	return branch < 0 and not data.branches.is_empty()


func upgrade_cost() -> int:
	return data.upgrade_cost(level)


## Paie l'amélioration et ouvre le chantier : le bâtisseur doit venir la faire.
## Au niveau 1, `branch_index` choisit la branche (ignoré ensuite : on reste sur la même).
func upgrade(branch_index: int = 0) -> void:
	if needs_branch_choice():
		branch = clampi(branch_index, 0, data.branches.size() - 1)
	_pending_cost = upgrade_cost()
	total_spent += _pending_cost
	level += 1
	build_progress = 0.0
	queue_redraw()


## Le chantier en cours est remboursé en entier, le reste à hauteur de la part de revente.
func sell_value() -> int:
	return int(floor((total_spent - _pending_cost) * rules.sell_refund)) + _pending_cost


func _draw_progress(half: float) -> void:
	draw_rect(Rect2(-half + 3, half - 8, (_size - 6), 5), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-half + 3, half - 8, (_size - 6) * build_progress, 5), Color(1, 0.85, 0.35))


func _find_target() -> Enemy:
	var best: Enemy = null
	var best_left := INF
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		if enemy.is_flying() and not data.hits_air:
			continue
		if enemy.global_position.distance_to(global_position) > attack_range():
			continue
		var left := enemy.remaining_distance()
		if left < best_left:
			best_left = left
			best = enemy
	return best
