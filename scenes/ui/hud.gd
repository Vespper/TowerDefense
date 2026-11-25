class_name Hud
extends CanvasLayer
## Interface : or, vies, vague, essences et éléments, boutons de construction et panneau de la tour choisie.
## Ne contient pas de règle : il affiche ce que Main lui donne et lui renvoie les clics par signaux.

signal build_requested(index: int)
signal start_wave_requested
signal upgrade_requested
signal sell_requested
signal speed_toggled
signal element_requested(element: Element.Type)

@onready var _gold_label: Label = %GoldLabel
@onready var _lives_label: Label = %LivesLabel
@onready var _wave_label: Label = %WaveLabel
@onready var _start_button: Button = %StartButton
@onready var _speed_button: Button = %SpeedButton
@onready var _build_list: GridContainer = %BuildList
@onready var _selection_panel: PanelContainer = %SelectionPanel
@onready var _selection_title: Label = %SelectionTitle
@onready var _selection_stats: Label = %SelectionStats
@onready var _upgrade_button: Button = %UpgradeButton
@onready var _sell_button: Button = %SellButton
@onready var _message_label: Label = %MessageLabel
@onready var _essence_label: Label = %EssenceLabel
@onready var _element_wheel: ElementWheel = %ElementWheel

var _build_buttons: Array[Button] = []


func _ready() -> void:
	_start_button.pressed.connect(start_wave_requested.emit)
	_speed_button.pressed.connect(speed_toggled.emit)
	_upgrade_button.pressed.connect(upgrade_requested.emit)
	_sell_button.pressed.connect(sell_requested.emit)
	show_selection(null)
	show_message("")
	_element_wheel.element_pressed.connect(element_requested.emit)


func set_tower_types(towers: Array[TowerData]) -> void:
	for b in _build_buttons:
		b.queue_free()
	_build_buttons.clear()
	for i in towers.size():
		var t := towers[i]
		var b := Button.new()
		b.text = "%d %s" % [i + 1, t.display_name]
		b.custom_minimum_size = Vector2(130, 0)
		b.tooltip_text = "%s — %s, %d or\n%s" % [t.display_name, Element.display_name(t.element), t.cost, t.description]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 14)
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_color_override("font_color", Element.color(t.element))
		b.pressed.connect(build_requested.emit.bind(i))
		_build_list.add_child(b)
		_build_buttons.append(b)


func set_build_selection(index: int) -> void:
	for i in _build_buttons.size():
		_build_buttons[i].set_pressed_no_signal(i == index)


## `unlocked[i]` : la tour i est disponible (élément débloqué).
func set_gold(gold: int, towers: Array[TowerData], unlocked: Array[bool]) -> void:
	_gold_label.text = "Or : %d" % gold
	for i in mini(towers.size(), _build_buttons.size()):
		var t := towers[i]
		_build_buttons[i].disabled = t.cost > gold or not unlocked[i]
		if unlocked[i]:
			_build_buttons[i].text = "%d %s · %d" % [i + 1, t.display_name, t.cost]
		else:
			_build_buttons[i].text = "%d %s" % [i + 1, t.display_name]


## Essences restantes et éléments débloqués (Element.Type -> true).
func set_elements(essences: int, owned: Dictionary, can_buy: bool) -> void:
	_essence_label.text = "Éléments — essences : %d" % essences
	_element_wheel.set_state(owned, essences > 0 and can_buy)


func set_lives(lives: int) -> void:
	_lives_label.text = "Vies : %d" % lives


## `spawning` : la vague `number` est en train d'apparaître ; sinon `number` est la prochaine,
## lancée automatiquement dans `seconds_left` secondes (ou plus tôt, contre `early_bonus` or).
func set_wave(number: int, total: int, preview: String, spawning: bool, seconds_left: float, early_bonus: int) -> void:
	if spawning:
		_wave_label.text = "Vague %d/%d : %s" % [number, total, preview]
		_start_button.text = "Vague en cours"
	elif number <= total:
		_wave_label.text = "Vague %d/%d dans %d s : %s" % [number, total, ceili(seconds_left), preview]
		_start_button.text = "Lancer maintenant (+%d or)" % early_bonus
	else:
		_wave_label.text = "Toutes les vagues sont lancées"
		_start_button.text = "Dernière vague"
	_start_button.disabled = spawning or number > total


func set_speed(multiplier: float) -> void:
	_speed_button.text = "Vitesse x%d (F)" % int(multiplier)


func show_selection(tower: Tower) -> void:
	_selection_panel.visible = tower != null
	if tower == null:
		return
	var d := tower.data
	_selection_title.text = "%s niv. %d" % [d.display_name, tower.level]
	if tower.is_upgrading():
		_selection_title.text = "%s → niv. %d : %d %%" % [d.display_name, tower.level, roundi(tower.build_progress * 100.0)]
	elif not tower.is_built():
		_selection_title.text = "%s — chantier %d %%" % [d.display_name, roundi(tower.build_progress * 100.0)]
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
	if not tower.is_built():
		_upgrade_button.text = "En construction"
		_upgrade_button.disabled = true
	elif tower.can_upgrade():
		_upgrade_button.text = "Améliorer (U) : %d or" % tower.upgrade_cost()
		_upgrade_button.disabled = false
	else:
		_upgrade_button.text = "Niveau max"
		_upgrade_button.disabled = true
	_sell_button.text = ("Vendre (V) : +%d or" if tower.is_built() or tower.is_upgrading() else "Annuler (V) : +%d or") % tower.sell_value()


func set_upgrade_affordable(affordable: bool) -> void:
	if _upgrade_button.text != "Niveau max" and _upgrade_button.text != "En construction":
		_upgrade_button.disabled = not affordable


func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.visible = text != ""
