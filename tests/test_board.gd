extends SceneTree
## Tests du terrain : chemin, interdiction de fermer le passage, éléments.
## Lancer : tools/test.sh tests/test_board.gd

var _failures: int = 0
var _checks: int = 0


var _board: Board


func _initialize() -> void:
	_board = Board.new()
	root.add_child(_board)


## Les vérifications tournent à la première image, une fois le _ready du terrain passé.
func _process(_delta: float) -> bool:
	var board := _board
	var straight := board.main_path_length()
	_check(straight == 24, "chemin droit de 24 cases (obtenu %d)" % straight)

	# Un mur vertical avec un trou : le passage reste ouvert, le chemin s'allonge
	for y in range(0, 14):
		_check(board.can_build(Vector2i(5, y)), "case (5, %d) constructible" % y)
		board.set_blocked(Vector2i(5, y), true)
	_check(board.main_path_length() > straight, "le mur allonge le chemin")
	_check(not board.can_build(Vector2i(5, 14)), "interdit de fermer le dernier trou")
	_check(not board.can_build(board.spawn_cell), "interdit sur l'entrée")
	_check(not board.can_build(board.exit_cell), "interdit sur la sortie")
	_check(not board.can_build(Vector2i(5, 3)), "interdit sur une case déjà prise")
	_check(not board.can_build(Vector2i(-1, 3)), "interdit hors du terrain")

	# Un ennemi sur une case l'empêche d'être construite
	var on_cell: Array[Vector2] = [board.cell_to_world(Vector2i(10, 10))]
	_check(not board.can_build(Vector2i(10, 10), on_cell), "interdit sous un ennemi")
	_check(board.can_build(Vector2i(12, 10), on_cell), "autorisé loin de l'ennemi")

	# Cycle des éléments
	var rules := GameRules.new()
	_check(rules.element_multiplier(Element.Type.WATER, Element.Type.FIRE) == rules.strong_multiplier, "Eau forte contre Feu")
	_check(rules.element_multiplier(Element.Type.FIRE, Element.Type.WATER) == rules.weak_multiplier, "Feu faible contre Eau")
	_check(rules.element_multiplier(Element.Type.FIRE, Element.Type.EARTH) == 1.0, "Feu neutre contre Terre")
	_check(rules.element_multiplier(Element.Type.NONE, Element.Type.FIRE) == 1.0, "Neutre sans bonus")

	print("Résultat : %s — %d/%d vérifications" % ["OK" if _failures == 0 else "ÉCHEC", _checks - _failures, _checks])
	quit(1 if _failures > 0 else 0)
	return true


func _check(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		printerr("ERROR: échec : %s" % label)
