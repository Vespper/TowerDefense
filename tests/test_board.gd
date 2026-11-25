extends SceneTree
## Tests du terrain (chemin fixe, cases constructibles) et du cycle des éléments.
## Lancer : tools/test.sh tests/test_board.gd

const MAP := preload("res://data/maps/serpent.tres")

var _failures: int = 0
var _checks: int = 0
var _board: Board


func _initialize() -> void:
	_board = Board.new()
	_board.map = MAP
	root.add_child(_board)


## Les vérifications tournent à la première image, une fois le _ready du terrain passé.
func _process(_delta: float) -> bool:
	var board := _board
	var cells := board.path_cells()
	_check(cells[0] == MAP.waypoints[0] and cells[-1] == MAP.waypoints[-1], "le chemin va de l'entrée à la sortie")
	var continuous := true
	for i in range(1, cells.size()):
		if absi(cells[i].x - cells[i - 1].x) + absi(cells[i].y - cells[i - 1].y) != 1:
			continuous = false
	_check(continuous, "le chemin est continu, case par case (%d cases)" % cells.size())
	_check(board.path_points().size() == MAP.waypoints.size() + 2, "points du chemin : bords + coins")

	_check(not board.can_build(Vector2i(5, 2)), "interdit sur le chemin")
	_check(board.can_build(Vector2i(5, 4)), "autorisé hors du chemin")
	_check(not board.can_build(Vector2i(-1, 3)), "interdit hors du terrain")
	board.set_occupied(Vector2i(5, 4), true)
	_check(not board.can_build(Vector2i(5, 4)), "interdit sur une case prise")
	board.set_occupied(Vector2i(5, 4), false)
	_check(board.can_build(Vector2i(5, 4)), "case libérée après la vente")

	# Cycle des éléments : chacun bat le suivant, et le dernier bat le premier
	var rules := GameRules.new()
	var all := Element.ALL
	for i in all.size():
		var a: Element.Type = all[i]
		var b: Element.Type = all[(i + 1) % all.size()]
		_check(rules.element_multiplier(a, b) == rules.strong_multiplier, "%s fort contre %s" % [Element.display_name(a), Element.display_name(b)])
		_check(rules.element_multiplier(b, a) == rules.weak_multiplier, "%s faible contre %s" % [Element.display_name(b), Element.display_name(a)])
	_check(rules.element_multiplier(Element.Type.LIGHT, Element.Type.FIRE) == 1.0, "Lumière neutre contre Feu")
	_check(rules.element_multiplier(Element.Type.NONE, Element.Type.FIRE) == 1.0, "Neutre sans bonus")
	_check(rules.gives_essence(4) and not rules.gives_essence(5), "essence toutes les 4 vagues")

	print("Résultat : %s — %d/%d vérifications" % ["OK" if _failures == 0 else "ÉCHEC", _checks - _failures, _checks])
	quit(1 if _failures > 0 else 0)
	return true


func _check(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		printerr("ERROR: échec : %s" % label)
