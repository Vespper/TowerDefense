extends SceneTree
## Contrôles simulés : commander une tour à la souris, attendre que le bâtisseur la construise,
## l'améliorer, la vendre, débloquer un élément, déplacer le bâtisseur au clavier.
## Lancer : tools/test.sh tests/test_input.gd

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const MAX_FRAMES := 1200

var _main: Main
var _frame: int = 0
var _step: int = 0
var _failures: int = 0
var _checks: int = 0
var _cell := Vector2i(6, 3)
var _builder_start: Vector2
var _gold_before_call: int = 0
var _bonus_expected: int = 0


func _initialize() -> void:
	_main = MAIN_SCENE.instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame > MAX_FRAMES:
		_check(false, "délai dépassé à l'étape %d" % _step)
		return _finish()
	match _step:
		0:
			if _frame < 2:
				return false
			_key(KEY_1)
			_click(_main.board.cell_to_world(_cell))
			_step = 1
		1:
			_check(_main.towers().size() == 1, "clic gauche : chantier d'Arbalète posé")
			_check(_main.gold == _main.rules.start_gold - _main.tower_types[0].cost, "coût de l'Arbalète dépensé")
			var site: Tower = _main.towers()[0]
			_check(not site.is_built(), "la tour n'est pas construite tout de suite")
			_check(not site.can_upgrade(), "pas d'amélioration pendant le chantier")
			_click(_main.board.cell_to_world(_cell))
			_check(_main.towers().size() == 1, "pas de second chantier sur la même case")
			_key(KEY_ESCAPE)
			_step = 2
		2:
			# Attendre que le bâtisseur arrive et construise
			var site: Tower = _main.towers()[0]
			if site.is_built():
				_check(_main.builder.global_position.distance_to(site.global_position) <= _main.builder.data.build_reach + 1.0, "le bâtisseur est allé à la case")
				_check(_main.builder.pending_orders() == 0, "file de chantiers vide")
				_click(_main.board.cell_to_world(_cell))
				_key(KEY_I)
				_step = 3
		3:
			var t: Tower = _main.towers()[0]
			_check(t.level == 2, "I : amélioration vers le niveau 2 payée")
			_check(t.branch == 1 and t.chosen_branch().display_name == "Rafale", "I : branche Rafale choisie")
			_check(t.fire_rate() > t.data.fire_rate, "Rafale : la cadence augmente")
			_check(t.is_upgrading() and not t.is_built(), "la tour est hors service pendant l'amélioration")
			_step = 30
		30:
			var t: Tower = _main.towers()[0]
			if t.is_built():
				_check(t.level == 2, "le bâtisseur a fini l'amélioration")
				_key(KEY_V)
				_step = 4
		4:
			_check(_main.towers().is_empty(), "V : tour vendue")
			_check(_main.board.can_build(_cell), "case libérée")
			_check(not _main.is_unlocked(3), "tour de Lumière bloquée au départ")
			_check(_main.buy_element(Element.Type.FERVOR), "stigmate dépensé pour la Ferveur")
			_check(_main.is_unlocked(3) and _main.essences == _main.rules.start_essences - 1, "tour de Lumière débloquée")
			# Un chantier vendu avant la fin est remboursé en entier
			var gold := _main.gold
			var site := _main.try_build(0, _cell)
			_main.sell(site)
			_check(_main.gold == gold, "chantier annulé remboursé en entier")
			_builder_start = _main.builder.global_position
			Input.action_press("move_right")
			_step = 5
		5:
			if _main.builder.global_position.x > _builder_start.x + 40.0:
				Input.action_release("move_right")
				_check(true, "le bâtisseur se déplace au clavier")
				_check(_main.wave_index == 0 and _main.next_wave_in > 1.0, "la première vague attend son compte à rebours")
				_gold_before_call = _main.gold
				_bonus_expected = _main.rules.early_call_bonus(_main.next_wave_in)
				_key(KEY_SPACE)
				_step = 6
		6:
			_check(_main.wave_index == 1 and _main.spawner.is_spawning(), "Espace : vague lancée en avance")
			_check(_bonus_expected > 0 and _main.gold == _gold_before_call + _bonus_expected, "bonus d'or pour l'avance (+%d)" % _bonus_expected)
			return _finish()
	return false


func _finish() -> bool:
	print("Résultat : %s — %d/%d vérifications" % ["OK" if _failures == 0 else "ÉCHEC", _checks - _failures, _checks])
	quit(1 if _failures > 0 else 0)
	return true


func _key(code: Key) -> void:
	for pressed in [true, false]:
		var e := InputEventKey.new()
		e.physical_keycode = code
		e.keycode = code
		e.pressed = pressed
		root.push_input(e)


func _click(world: Vector2) -> void:
	# Coordonnées de la fenêtre (en headless elle est minuscule et l'image est mise à l'échelle)
	var pos: Vector2 = root.get_final_transform() * world
	var move := InputEventMouseMotion.new()
	move.position = pos
	root.push_input(move)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = pos
		e.pressed = pressed
		root.push_input(e)


func _check(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		printerr("ERROR: échec : %s" % label)
