extends SceneTree
## Contrôles à la souris et au clavier, simulés : choisir une tour, la poser, l'améliorer, la vendre.
## Lancer : tools/test.sh tests/test_input.gd

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _main: Main
var _frame: int = 0
var _failures: int = 0
var _checks: int = 0
var _cell := Vector2i(6, 4)


func _initialize() -> void:
	_main = MAIN_SCENE.instantiate()
	root.add_child(_main)


func _process(_delta: float) -> bool:
	_frame += 1
	match _frame:
		2:
			_key(KEY_1)
			_click(_main.board.cell_to_world(_cell))
		3:
			_check(_main.towers().size() == 1, "clic gauche : une Flèche posée")
			_check(_main.gold == _main.rules.start_gold - 10, "10 or dépensés")
			_click(_main.board.cell_to_world(_cell))
			_check(_main.towers().size() == 1, "pas de seconde tour sur la même case")
			_key(KEY_ESCAPE)
			_click(_main.board.cell_to_world(_cell))
		4:
			_key(KEY_U)
		5:
			var t: Tower = _main.towers()[0]
			_check(t.level == 2, "U : tour améliorée au niveau 2")
			_key(KEY_S)
		6:
			_check(_main.towers().is_empty(), "S : tour vendue")
			_check(not _main.board.is_blocked(_cell), "case libérée")
			_key(KEY_SPACE)
		7:
			_check(_main.state == Main.State.WAVE, "Espace : vague lancée")
			print("Résultat : %s — %d/%d vérifications" % ["OK" if _failures == 0 else "ÉCHEC", _checks - _failures, _checks])
			quit(1 if _failures > 0 else 0)
			return true
	return false


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
