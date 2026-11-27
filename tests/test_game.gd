extends SceneTree
## Partie complète jouée par un « joueur automatique » : il débloque les éléments dans un ordre fixe,
## pose ses tours aux cases qui couvrent le plus de chemin, puis les améliore entre les vagues.
## Lancer : tools/test.sh tests/test_game.gd
## Options après « -- » : « passive » pour ne rien construire (doit mener à la défaite),
## « rush » pour lancer chaque vague dès que possible (bonus d'avance, vagues qui se chevauchent),
## « shot=60 » pour enregistrer une capture d'écran à 60 s de jeu (tools/screenshot.sh, pas en headless).

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const MAX_SECONDS := 3600.0
const ELEMENT_ORDER: Array[Element.Type] = [
	Element.Type.ASH, Element.Type.MADNESS, Element.Type.FERVOR,
	Element.Type.ABYSS, Element.Type.ROT, Element.Type.BONE,
]
## Ordre des achats : nom de tour de base, ou « element » pour la prochaine tour d'élément débloquée.
const BUILD_CYCLE := ["crossbow", "trebuchet", "element", "censer", "element", "crossbow", "element"]
## Au-delà de ce nombre de tours, on améliore une fois sur deux.
const BUILD_ONLY_UNTIL := 10
const MAX_TOWERS := 30
## Points de score perdus par case d'éloignement de la meilleure case.
const SPREAD_PENALTY := 0.2

var _main: Main
var _passive: bool = false
var _elapsed: float = 0.0
var _last_wave: int = 0
var _shot_at: float = -1.0
var _shot_path: String = "user://screenshot.png"
var _spots: Array[Vector2i] = []
var _cycle_step: int = 0
var _element_turn: int = 0
var _upgrade_next: bool = false
var _ready_done: bool = false
var _rush: bool = false


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "passive":
			_passive = true
		elif arg.begins_with("shot="):
			_shot_at = float(arg.trim_prefix("shot="))
		elif arg == "rush":
			_rush = true
		elif arg.begins_with("out="):
			_shot_path = arg.trim_prefix("out=")
	_main = MAIN_SCENE.instantiate()
	root.add_child(_main)
	print("Test partie (%s)" % ("passif" if _passive else "joueur automatique"))


func _process(delta: float) -> bool:
	if not _ready_done:
		# Première image : la partie a fini son _ready
		_ready_done = true
		_rank_spots()
	_elapsed += delta
	if _shot_at >= 0.0 and _elapsed >= _shot_at:
		_shot_at = -1.0
		var err := root.get_texture().get_image().save_png(_shot_path)
		print("Résultat : capture %s (%s)" % [_shot_path, error_string(err)])
		_report()
		return true
	if _main.is_finished() or _elapsed > MAX_SECONDS:
		_report()
		return true
	if _main.waves_cleared != _last_wave:
		_last_wave = _main.waves_cleared
		print("  vague %d finie à %.0f s : vies %d, or %d, %d tours, corruptions %d" % [
			_last_wave, _elapsed, _main.lives, _main.gold, _main.towers().size(), _main.elements.size()])
	if not _passive:
		_play()
	if _rush:
		_main.start_next_wave()
	return false


func _play() -> void:
	while _main.essences > 0 and _element_turn < ELEMENT_ORDER.size():
		_main.buy_element(ELEMENT_ORDER[_element_turn])
		_element_turn += 1
	var count := _main.towers().size()
	# Améliorer met la tour hors service : seulement entre deux vagues, une à la fois
	var can_upgrade_now := not _main.spawner.is_spawning() and _main.builder.pending_orders() == 0
	if count >= MAX_TOWERS and not can_upgrade_now:
		return
	if can_upgrade_now and (count >= MAX_TOWERS or (count >= BUILD_ONLY_UNTIL and _upgrade_next)):
		var best: Tower = null
		for t in _main.towers():
			if t.can_upgrade() and (best == null or t.upgrade_cost() < best.upgrade_cost()):
				best = t
		if best != null:
			# Alterne les branches selon la case, pour jouer les deux côtés de l'arbre
			if _main.try_upgrade(best, (best.cell.x + best.cell.y) % 2):
				_upgrade_next = false
			return
	var index := _next_type()
	for cell in _spots:
		if _main.board.can_build(cell):
			if _main.can_build(index, cell) and _main.try_build(index, cell) != null:
				_cycle_step += 1
				_upgrade_next = true
			return


## Type de tour du prochain achat (index dans tower_types).
func _next_type() -> int:
	var wanted: String = BUILD_CYCLE[_cycle_step % BUILD_CYCLE.size()]
	if wanted == "element":
		var owned: Array[int] = []
		for i in _main.tower_types.size():
			if _main.tower_types[i].element != Element.Type.NONE and _main.is_unlocked(i):
				owned.append(i)
		if owned.is_empty():
			return 0
		return owned[(_cycle_step / BUILD_CYCLE.size()) % owned.size()]
	for i in _main.tower_types.size():
		if _main.tower_types[i].resource_path.get_file().get_basename() == wanted:
			return i
	return 0


## Cases constructibles, de celle qui couvre le plus de cases de chemin à celle qui en couvre le moins.
func _rank_spots() -> void:
	var board := _main.board
	var path := board.path_cells()
	var score := {}
	for x in board.columns:
		for y in board.rows:
			var cell := Vector2i(x, y)
			if not board.can_build(cell):
				continue
			var n := 0
			for p in path:
				if Vector2(p - cell).length() <= 3.0:
					n += 1
			score[cell] = n
			_spots.append(cell)
	_spots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return score[a] > score[b])
	# Sur une grande carte, regrouper les tours autour de la meilleure case (comme un joueur)
	var anchor := _spots[0]
	var value := {}
	for c in _spots:
		value[c] = score[c] - SPREAD_PENALTY * Vector2(c - anchor).length()
	_spots.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return value[a] > value[b])


func _report() -> void:
	var result := "VICTOIRE" if _main.state == Main.State.WON else "DÉFAITE"
	if not _main.is_finished():
		result = "TEMPS ÉCOULÉ"
	var levels := 0
	for t in _main.towers():
		levels += t.level
	print("Résultat : %s après %.0f s — %d vagues vaincues sur %d, vies %d/%d, or %d, %d tours (niveaux cumulés %d), %d corruptions" % [
		result, _elapsed, _main.waves_cleared, _main.waves.size(),
		_main.lives, _main.rules.start_lives, _main.gold, _main.towers().size(), levels, _main.elements.size()
	])
