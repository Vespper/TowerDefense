class_name Main
extends Node2D
## Une partie : or, vies, essences et éléments, vagues, pose des tours.
## Relie le terrain, les vagues et l'interface.

signal game_ended(won: bool)

enum State { BUILD, WAVE, WON, LOST }

const TOWER_SCENE := preload("res://scenes/towers/tower.tscn")
const SPEEDS: Array[float] = [1.0, 2.0, 3.0]

@export var rules: GameRules
@export var tower_types: Array[TowerData] = []
@export var waves: Array[WaveData] = []

var gold: int = 0
var lives: int = 0
## Index de la prochaine vague (ou de la vague en cours).
var wave_index: int = 0
var state: State = State.BUILD
## Essences pas encore dépensées.
var essences: int = 0
## Éléments débloqués (Element.Type -> true).
var elements: Dictionary = {}

var _alive: int = 0
var _build_index: int = -1
var _selected: Tower
var _towers_by_cell: Dictionary = {}
var _speed_index: int = 0
## Dernière position de la souris dans le monde (lue dans les événements, pas dans le système).
var _mouse_world: Vector2 = Vector2(-1000, -1000)

@onready var board: Board = $Board
@onready var towers_root: Node2D = $Towers
@onready var enemies_root: Node2D = $Enemies
@onready var projectiles_root: Node2D = $Projectiles
@onready var spawner: WaveSpawner = $WaveSpawner
@onready var hud: Hud = $Hud
@onready var builder: Builder = $Builder


func _ready() -> void:
	Engine.time_scale = 1.0
	gold = rules.start_gold
	lives = rules.start_lives
	essences = rules.start_essences
	var board_rect := Rect2(board.global_position, Vector2(board.columns, board.rows) * board.cell_size)
	builder.bounds = board_rect.grow(-12)
	builder.global_position = board.cell_to_world(Vector2i(board.columns / 2, board.rows / 2))
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	hud.build_requested.connect(select_build)
	hud.start_wave_requested.connect(start_next_wave)
	hud.upgrade_requested.connect(func() -> void: try_upgrade(_selected))
	hud.sell_requested.connect(func() -> void: sell(_selected))
	hud.speed_toggled.connect(_toggle_speed)
	hud.element_requested.connect(buy_element)
	hud.set_tower_types(tower_types)
	_refresh_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_mouse_world = get_canvas_transform().affine_inverse() * (event as InputEventMouse).position
	if event.is_action_pressed("restart") and is_finished():
		get_tree().reload_current_scene()
		return
	if is_finished():
		return
	for i in tower_types.size():
		if event.is_action_pressed("select_tower_%d" % (i + 1)):
			select_build(i)
			return
	if event.is_action_pressed("cancel_build"):
		select_build(-1)
		_select_tower(null)
	elif event.is_action_pressed("start_wave"):
		start_next_wave()
	elif event.is_action_pressed("upgrade_tower"):
		try_upgrade(_selected)
	elif event.is_action_pressed("sell_tower"):
		sell(_selected)
	elif event.is_action_pressed("toggle_speed"):
		_toggle_speed()
	elif event is InputEventMouseMotion:
		_update_ghost()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := board.world_to_cell(_mouse_world)
		if _build_index >= 0:
			try_build(_build_index, cell)
		else:
			_select_tower(_towers_by_cell.get(cell))


func is_finished() -> bool:
	return state == State.WON or state == State.LOST


## Choisit le type de tour à poser (-1 = aucun).
func select_build(index: int) -> void:
	_build_index = index if index != _build_index else -1
	if _build_index >= 0:
		_select_tower(null)
	hud.set_build_selection(_build_index)
	_update_ghost()


func has_element(element: Element.Type) -> bool:
	return element == Element.Type.NONE or elements.has(element)


## Une tour est disponible si son élément est débloqué (les tours neutres le sont toujours).
func is_unlocked(index: int) -> bool:
	return has_element(tower_types[index].element)


func can_build(index: int, cell: Vector2i) -> bool:
	return is_unlocked(index) and tower_types[index].cost <= gold and board.can_build(cell)


## Dépense une essence pour débloquer un élément.
func buy_element(element: Element.Type) -> bool:
	if is_finished() or essences <= 0 or has_element(element):
		return false
	essences -= 1
	elements[element] = true
	_refresh_hud()
	return true


func try_build(index: int, cell: Vector2i) -> Tower:
	if is_finished() or not can_build(index, cell):
		return null
	var data := tower_types[index]
	gold -= data.cost
	var tower: Tower = TOWER_SCENE.instantiate()
	tower.setup(data, rules, cell, board.cell_size, projectiles_root)
	towers_root.add_child(tower)
	tower.global_position = board.cell_to_world(cell)
	_towers_by_cell[cell] = tower
	board.set_occupied(cell, true)
	tower.built.connect(func(_t: Tower) -> void: _refresh_hud())
	builder.order(tower)
	_refresh_hud()
	_update_ghost()
	return tower


func try_upgrade(tower: Tower) -> bool:
	if tower == null or is_finished() or not tower.can_upgrade() or tower.upgrade_cost() > gold:
		return false
	gold -= tower.upgrade_cost()
	tower.upgrade()
	_refresh_hud()
	return true


func sell(tower: Tower) -> void:
	if tower == null or is_finished():
		return
	gold += tower.sell_value()
	_towers_by_cell.erase(tower.cell)
	board.set_occupied(tower.cell, false)
	if tower == _selected:
		_select_tower(null)
	tower.queue_free()
	_refresh_hud()


func start_next_wave() -> bool:
	if state != State.BUILD or wave_index >= waves.size():
		return false
	state = State.WAVE
	spawner.start(waves[wave_index])
	_refresh_hud()
	return true


func towers() -> Array[Tower]:
	var result: Array[Tower] = []
	for t in _towers_by_cell.values():
		result.append(t)
	return result


func _on_enemy_spawned(enemy: Enemy) -> void:
	_alive += 1
	enemy.died.connect(_on_enemy_died)
	enemy.reached_exit.connect(_on_enemy_reached_exit)


func _on_enemy_died(enemy: Enemy) -> void:
	gold += enemy.data.bounty
	_on_enemy_removed()


func _on_enemy_reached_exit(enemy: Enemy) -> void:
	lives = maxi(lives - enemy.data.lives_cost, 0)
	if lives == 0 and state != State.LOST:
		_end_game(false)
		return
	_on_enemy_removed()


func _on_enemy_removed() -> void:
	_alive -= 1
	if state == State.WAVE and _alive <= 0 and not spawner.is_spawning():
		wave_index += 1
		# Intérêts sur l'or gardé, puis bonus de fin de vague
		gold += rules.interest(gold) + rules.wave_bonus(wave_index)
		if rules.gives_essence(wave_index):
			essences += 1
		if wave_index >= waves.size():
			_end_game(true)
			return
		state = State.BUILD
	_refresh_hud()


func _end_game(won: bool) -> void:
	state = State.WON if won else State.LOST
	spawner.stop()
	enemies_root.process_mode = Node.PROCESS_MODE_DISABLED
	towers_root.process_mode = Node.PROCESS_MODE_DISABLED
	projectiles_root.process_mode = Node.PROCESS_MODE_DISABLED
	select_build(-1)
	_select_tower(null)
	Engine.time_scale = 1.0
	_refresh_hud()
	hud.show_message(("Victoire !" if won else "Défaite") + "\nR pour rejouer")
	game_ended.emit(won)


func _select_tower(tower: Tower) -> void:
	if is_instance_valid(_selected):
		_selected.selected = false
	_selected = tower
	if _selected != null:
		_selected.selected = true
	_refresh_hud()


func _toggle_speed() -> void:
	_speed_index = (_speed_index + 1) % SPEEDS.size()
	Engine.time_scale = SPEEDS[_speed_index]
	hud.set_speed(SPEEDS[_speed_index])


func _update_ghost() -> void:
	if _build_index < 0 or is_finished():
		board.clear_ghost()
		return
	var cell := board.world_to_cell(_mouse_world)
	board.set_ghost(cell, can_build(_build_index, cell), tower_types[_build_index].attack_range)


func _wave_preview(index: int) -> String:
	if index >= waves.size():
		return ""
	var w := waves[index]
	var text := "%d × %s (%s)" % [w.count, w.enemy.display_name, Element.display_name(w.element)]
	if w.enemy.flying:
		text += " — volants"
	return text


func _refresh_hud() -> void:
	var unlocked: Array[bool] = []
	for i in tower_types.size():
		unlocked.append(is_unlocked(i))
	hud.set_gold(gold, tower_types, unlocked)
	hud.set_elements(essences, elements, not is_finished())
	hud.set_lives(lives)
	var shown := mini(wave_index, waves.size() - 1) if state == State.WAVE else wave_index
	hud.set_wave(wave_index + 1, waves.size(), _wave_preview(shown), state == State.WAVE)
	hud.show_selection(_selected)
	if _selected != null:
		hud.set_upgrade_affordable(_selected.upgrade_cost() <= gold)
