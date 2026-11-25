class_name Hud
extends CanvasLayer
## Interface : or, vies, vague, boutons de construction et panneau de la tour choisie.
## Ne contient pas de règle : il affiche ce que Main lui donne et lui renvoie les clics par signaux.

signal build_requested(index: int)
signal start_wave_requested
signal upgrade_requested
signal sell_requested
signal speed_toggled

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _start_button: Button = %StartButton
@onready var _speed_button: Button = %SpeedButton
@onready var _build_list: VBoxContainer = %BuildList
@onready var _selection_panel: PanelContainer = %SelectionPanel
@onready var _selection_title: Label = %SelectionTitle
@onready var _selection_stats: Label = %SelectionStats
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _sell_button: Button = %SellButton
@onready var _message_label: Label = %MessageLabel

var _build_buttons: Array[Button] = []


func _ready() -> void:
	_start_button.pressed.connect(start_wave_requested.emit)
	_speed_button.pressed.connect(speed_toggled.emit)
	_upgrade_button.pressed.connect(upgrade_requested.emit)
	_sell_button.pressed.connect(sell_requested.emit)
	show_selection(null)
	show_message("")


func set_tower_types(towers: Array[TowerData]) -> void:
	for b in _build_buttons:
		b.queue_free()
	_build_buttons.clear()
	for i in towers.size():
		var t := towers[i]
		var b := Button.new()
		b.text = "%d. %s (%d or)" % [i + 1, t.display_name, t.cost]
		b.tooltip_text = "%s — %s\n%s" % [t.display_name, Element.display_name(t.element), t.description]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_color_override("font_color", Element.color(t.element))
		b.pressed.connect(build_requested.emit.bind(i))
		_build_list.add_child(b)
		_build_buttons.append(b)


func set_build_selection(index: int) -> void:
	for i in _build_buttons.size():
		_build_buttons[i].set_pressed_no_signal(i == index)


func set_gold(gold: int, towers: Array[TowerData]) -> void:
	_gold_label.text = "Or : %d" % gold
	for i in mini(towers.size(), _build_buttons.size()):
		_build_buttons[i].disabled = towers[i].cost > gold


func set_lives(lives: int) -> void:
	_lives_label.text = "Vies : %d" % lives


func set_wave(number: int, total: int, preview: String, in_progress: bool) -> void:
	if in_progress:
		_wave_label.text = "Vague %d/%d en cours : %s" % [number, total, preview]
	elif number <= total:
		_wave_label.text = "Prochaine vague %d/%d : %s" % [number, total, preview]
	else:
		_wave_label.text = "Toutes les vagues sont passées"
	_start_button.disabled = in_progress or number > total


func set_speed(multiplier: float) -> void:
	_speed_button.text = "Vitesse x%d (F)" % int(multiplier)


func show_selection(tower: Tower) -> void:
	_selection_panel.visible = tower != null
	if tower == null:
		return
	var d := tower.data
	_selection_title.text = "%s niv. %d" % [d.display_name, tower.level]
	_selection_title.add_theme_color_override("font_color", Element.color(d.element))
	var lines: PackedStringArray = [
		"Élément : %s" % Element.display_name(d.element),
		"Dégâts : %.0f  ·  %.1f tirs/s" % [tower.damage(), d.fire_rate],
		"Portée : %.1f cases" % (d.attack_range / 40.0),
	]
	if d.splash_radius > 0.0:
		lines.append("Zone : %.0f px" % d.splash_radius)
	if d.slow_factor < 1.0:
		lines.append("Ralentit de %d %% (%.1f s)" % [roundi((1.0 - d.slow_factor) * 100.0), d.slow_duration])
	if d.poison_dps > 0.0:
		lines.append("Poison : %.0f/s pendant %.0f s" % [tower.poison_dps(), d.poison_duration])
	_selection_stats.text = "\n".join(lines)
	if tower.can_upgrade():
		_upgrade_button.text = "Améliorer (U) : %d or" % tower.upgrade_cost()
		_upgrade_button.disabled = false
	else:
		_upgrade_button.text = "Niveau max"
		_upgrade_button.disabled = true
	_sell_button.text = "Vendre (S) : +%d or" % tower.sell_value()


func set_upgrade_affordable(affordable: bool) -> void:
	if _upgrade_button.text != "Niveau max":
		_upgrade_button.disabled = not affordable


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = text != ""
