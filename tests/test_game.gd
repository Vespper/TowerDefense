extends SceneTree
## Partie complète jouée par un « joueur automatique » : il construit un labyrinthe en serpentin,
## mêle des tours élémentaires aux Flèches, puis améliore ses tours avec l'or restant.
## Lancer : tools/test.sh tests/test_game.gd
## Options après « -- » : « passive » pour ne rien construire (doit mener à la défaite),
## « shot=60 » pour enregistrer une capture d'écran à 60 s de jeu (tools/screenshot.sh, pas en headless).

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const MAX_SECONDS := 1800.0
## Colonnes des murs du serpentin ; le trou alterne en haut et en bas.
const WALL_COLUMNS := [3, 6, 9, 12, 15, 18]
## Une tour élémentaire toutes les N cases de mur (les autres sont des Flèches).
const ELEMENT_EVERY := 4

var _main: Main
var _plan: Array[Dictionary] = []
var _passive: bool = false
var _elapsed: float = 0.0
var _element_turn: int = 0
var _last_wave: int = 0
var _shot_at: float = -1.0
var _shot_path: String = "user://screenshot.png"


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg == "passive":
			_passive = true
		elif arg.begins_with("shot="):
			_shot_at = float(arg.trim_prefix("shot="))
		elif arg.begins_with("out="):
			_shot_path = arg.trim_prefix("out=")
	_main = MAIN_SCENE.instantiate()
	root.add_child(_main)
	print("Test partie (%s)" % ("passif" if _passive else "joueur automatique"))


func _process(delta: float) -> bool:
	if _plan.is_empty():
		# Première image : la partie a fini son _ready
		_build_plan()
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
	if _main.wave_index != _last_wave:
		_last_wave = _main.wave_index
		print("  vague %d finie à %.0f s : vies %d, or %d, %d tours, chemin %d cases" % [
			_last_wave, _elapsed, _main.lives, _main.gold, _main.towers().size(), _main.board.main_path_length()])
	if not _passive:
		_play()
	_main.start_next_wave()
	return false


func _play() -> void:
	# Construire le plan dans l'ordre ; une case momentanément impossible (ennemi dessus) est retentée plus tard.
	for i in _plan.size():
		var step: Dictionary = _plan[i]
		if step.done:
			continue
		if _main.gold < _main.tower_types[step.type].cost:
			return
		if _main.try_build(step.type, step.cell) != null:
			step.done = true
		return
	# Plan terminé : améliorer la tour élémentaire la moins chère à améliorer
	var best: Tower = null
	for t in _main.towers():
		if t.can_upgrade() and (best == null or t.upgrade_cost() < best.upgrade_cost()):
			best = t
	if best != null:
		_main.try_upgrade(best)


func _build_plan() -> void:
	var board := _main.board
	var center := board.spawn_cell.y
	for w in WALL_COLUMNS.size():
		var x: int = WALL_COLUMNS[w]
		var gap: int = 0 if w % 2 == 0 else board.rows - 1
		var rows: Array[int] = []
		for y in board.rows:
			if y != gap:
				rows.append(y)
		# Du centre vers les bords : chaque tour posée allonge déjà le détour
		rows.sort_custom(func(a: int, b: int) -> bool: return absi(a - center) < absi(b - center))
		for k in rows.size():
			var type := 0
			if k % ELEMENT_EVERY == 1:
				type = 1 + (_element_turn % 4)
				_element_turn += 1
			_plan.append({"cell": Vector2i(x, rows[k]), "type": type, "done": false})


func _report() -> void:
	var result := "VICTOIRE" if _main.state == Main.State.WON else "DÉFAITE"
	if not _main.is_finished():
		result = "TEMPS ÉCOULÉ"
	var built := 0
	for s in _plan:
		if s.done:
			built += 1
	var levels := 0
	for t in _main.towers():
		levels += t.level
	print("Résultat : %s après %.0f s — vague %d/%d, vies %d/%d, or %d, %d tours (niveaux cumulés %d), chemin %d cases" % [
		result, _elapsed, mini(_main.wave_index + 1, _main.waves.size()), _main.waves.size(),
		_main.lives, _main.rules.start_lives, _main.gold, built, levels, _main.board.main_path_length()
	])
