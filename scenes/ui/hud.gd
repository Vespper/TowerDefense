class_name Hud
extends CanvasLayer
## Interface (maquette validée le 2026-11-27) :
## - barre du haut : or, vies, stigmates, annonce de la vague, lancer, vitesse, aide ;
## - colonne droite : prochaines vagues, roue des corruptions, minicarte ;
## - barre du bas : tour choisie, boutons de construction (base / corruptions), infos de ce qu'on survole.
## Construite en code dans `_build_layout`. Ne contient pas de règle : elle affiche ce que Main lui donne
## et lui renvoie les clics par signaux.

signal build_requested(index: int)
signal start_wave_requested
signal upgrade_requested(branch_index: int)
signal sell_requested
signal speed_toggled
signal element_requested(element: Element.Type)
signal elite_chosen(wave_index: int, element: Element.Type)
signal view_requested(world_position: Vector2)

## Taille des zones (px, écran de 1280 × 720). La zone de jeu visible est le reste.
const TOP_HEIGHT := 40.0
const SIDE_WIDTH := 250.0
const BOTTOM_HEIGHT := 150.0
const BUTTON_SIZE := Vector2(106, 32)

const COLOR_BG := Color(0.086, 0.082, 0.078)
const COLOR_BG_DARK := Color(0.078, 0.075, 0.07)
const COLOR_LINE := Color(0.17, 0.165, 0.15)
const COLOR_TEXT := Color(0.9, 0.88, 0.82)
const COLOR_DIM := Color(0.6, 0.58, 0.52)
const COLOR_GOLD := Color(0.95, 0.82, 0.42)
const COLOR_LIVES := Color(0.94, 0.48, 0.43)
const COLOR_STIGMA := Color(0.78, 0.61, 0.88)

const HELP_TEXT := """[b]Commandes[/b]

ZQSD / WASD / flèches : déplacer le bâtisseur
1 à 9 : choisir une tour, puis clic sur une case pour la commander
Clic sur une tour : la choisir · Clic sur une ruine : la démolir (or)
U / I : améliorer (au niveau 1, U = branche A, I = branche B)
V ou Suppr : vendre · Échap ou clic droit : annuler
Espace : lancer la vague en avance (contre de l'or)
P : pause (on peut encore donner des ordres) · F : vitesse
Molette : zoom · Clic molette glissé : déplacer la vue · C : recentrer
Clic sur la minicarte : y regarder · H : cette aide

[b]Rappels[/b]

Roue : chaque corruption fait ×2 à la suivante, ×0,5 à la précédente.
Élites : choisis leur corruption dans « Prochaines vagues » ; tue-les tous pour un stigmate de cette corruption.
Arbalète > Chair · Trébuchet > Carapace · Encensoir > Spectre
Terre de sa corruption : +25 % · terre de la corruption opposée : −25 %"""

var _gold_label: Label
var _lives_label: Label
var _stigma_label: Label
var _announce_label: Label
var _announce_tween: Tween
var _wave_label: Label
var _start_button: Button
var _speed_button: Button
var _upcoming_box: VBoxContainer
var _element_wheel: ElementWheel
var _minimap: Minimap
var _selection_title: Label
var _selection_stats: Label
var _selection_hint: Label
var _upgrade_button: Button
var _upgrade_button_alt: Button
var _sell_button: Button
var _base_row: HBoxContainer
var _corruption_row: HBoxContainer
var _info_label: RichTextLabel
var _message_panel: PanelContainer
var _message_label: Label
var _help_panel: PanelContainer

var _build_buttons: Array[Button] = []
var _towers: Array[TowerData] = []
## Texte d'infos par défaut (survol de la carte), remplacé pendant le survol d'un bouton.
var _map_info: String = ""
var _hovered_button: int = -1
var _last_upcoming: Array = []


func _ready() -> void:
	_build_layout()
	show_selection(null)
	show_message("")
	set_info("")
	set_speed(1.0)


## Zone de l'écran où l'on voit la carte (hors interface).
static func play_area() -> Rect2:
	return Rect2(0, TOP_HEIGHT, 1280 - SIDE_WIDTH, 720 - TOP_HEIGHT - BOTTOM_HEIGHT)


# --- Construction de l'interface ---------------------------------------------------------------

func _build_layout() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Barre du haut
	var top := _panel(root, Rect2(0, 0, 1280, TOP_HEIGHT), COLOR_BG)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 18)
	_margin(top, top_row, 14, 4)
	_gold_label = _label(top_row, "", 17, COLOR_GOLD)
	_lives_label = _label(top_row, "", 17, COLOR_LIVES)
	_stigma_label = _label(top_row, "", 17, COLOR_STIGMA)
	_wave_label = _label(top_row, "", 15, COLOR_TEXT)
	_wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wave_label.clip_text = true
	_start_button = _button(top_row, "", 14)
	_start_button.pressed.connect(start_wave_requested.emit)
	_speed_button = _button(top_row, "", 14)
	_speed_button.pressed.connect(speed_toggled.emit)
	var help_button := _button(top_row, "Aide (H)", 14)
	help_button.pressed.connect(toggle_help)

	# Colonne droite
	var side := _panel(root, Rect2(1280 - SIDE_WIDTH, TOP_HEIGHT, SIDE_WIDTH, 720 - TOP_HEIGHT - BOTTOM_HEIGHT), COLOR_BG_DARK)
	var side_box := VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 4)
	_margin(side, side_box, 12, 8)
	_header(side_box, "Prochaines vagues")
	_upcoming_box = VBoxContainer.new()
	_upcoming_box.add_theme_constant_override("separation", 3)
	side_box.add_child(_upcoming_box)
	_header(side_box, "Corruptions")
	_element_wheel = ElementWheel.new()
	_element_wheel.custom_minimum_size = Vector2(0, 132)
	_element_wheel.element_pressed.connect(element_requested.emit)
	side_box.add_child(_element_wheel)
	_header(side_box, "Carte")
	_minimap = Minimap.new()
	_minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_minimap.view_requested.connect(view_requested.emit)
	side_box.add_child(_minimap)

	# Barre du bas
	var bottom := _panel(root, Rect2(0, 720 - BOTTOM_HEIGHT, 1280, BOTTOM_HEIGHT), COLOR_BG)
	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 0)
	_margin(bottom, bottom_row, 0, 0)

	var sel := VBoxContainer.new()
	sel.custom_minimum_size = Vector2(330, 0)
	sel.add_theme_constant_override("separation", 2)
	_margin(bottom_row, sel, 14, 8)
	_selection_title = _label(sel, "", 16, COLOR_TEXT)
	_selection_stats = _label(sel, "", 13, COLOR_DIM)
	_selection_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_selection_stats.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_selection_hint = _label(sel, "Clique sur une tour pour la choisir.\nClique sur une ruine pour la démolir.", 13, COLOR_DIM)
	var sel_buttons := HBoxContainer.new()
	sel.add_child(sel_buttons)
	_upgrade_button = _button(sel_buttons, "", 12)
	_upgrade_button.pressed.connect(upgrade_requested.emit.bind(0))
	_upgrade_button_alt = _button(sel_buttons, "", 12)
	_upgrade_button_alt.pressed.connect(upgrade_requested.emit.bind(1))
	_sell_button = _button(sel_buttons, "", 12)
	_sell_button.pressed.connect(sell_requested.emit)
	_separator(bottom_row)

	var build := VBoxContainer.new()
	build.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build.add_theme_constant_override("separation", 3)
	_margin(bottom_row, build, 12, 6)
	_header(build, "Base")
	_base_row = HBoxContainer.new()
	_base_row.add_theme_constant_override("separation", 5)
	build.add_child(_base_row)
	_header(build, "Corruptions")
	_corruption_row = HBoxContainer.new()
	_corruption_row.add_theme_constant_override("separation", 5)
	build.add_child(_corruption_row)
	_separator(bottom_row)

	var info_box := VBoxContainer.new()
	info_box.custom_minimum_size = Vector2(SIDE_WIDTH - 26, 0)
	_margin(bottom_row, info_box, 12, 8)
	_info_label = RichTextLabel.new()
	_info_label.bbcode_enabled = true
	_info_label.fit_content = false
	_info_label.scroll_active = false
	_info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_info_label.add_theme_font_size_override("normal_font_size", 12)
	_info_label.add_theme_font_size_override("bold_font_size", 13)
	_info_label.add_theme_color_override("default_color", COLOR_DIM)
	_info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_box.add_child(_info_label)

	# Message au centre de la zone de jeu (pause, victoire, défaite)
	var area := play_area()
	_message_panel = PanelContainer.new()
	_message_panel.add_theme_stylebox_override("panel", _style(Color(0, 0, 0, 0.7), COLOR_GOLD.darkened(0.4), 8))
	_message_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_message_panel)
	_message_label = _label(null, "", 26, COLOR_GOLD)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_margin(_message_panel, _message_label, 24, 12)
	_message_panel.resized.connect(func() -> void:
		_message_panel.position = area.get_center() - _message_panel.size / 2.0)

	# Annonce temporaire en haut de la zone de jeu (stigmate gagné…)
	_announce_label = _label(root, "", 18, COLOR_STIGMA)
	_announce_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_announce_label.add_theme_constant_override("outline_size", 6)
	_announce_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announce_label.position = Vector2(area.position.x, area.position.y + 16)
	_announce_label.size = Vector2(area.size.x, 30)
	_announce_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_announce_label.visible = false

	# Fenêtre d'aide (H)
	_help_panel = PanelContainer.new()
	_help_panel.add_theme_stylebox_override("panel", _style(Color(0.05, 0.05, 0.045, 0.95), COLOR_LINE.lightened(0.2), 8))
	_help_panel.visible = false
	root.add_child(_help_panel)
	var help := RichTextLabel.new()
	help.bbcode_enabled = true
	help.fit_content = true
	help.custom_minimum_size = Vector2(620, 0)
	help.text = HELP_TEXT
	help.add_theme_font_size_override("normal_font_size", 14)
	help.add_theme_font_size_override("bold_font_size", 16)
	help.add_theme_color_override("default_color", COLOR_TEXT)
	_margin(_help_panel, help, 22, 16)
	_help_panel.resized.connect(func() -> void:
		_help_panel.position = area.get_center() - _help_panel.size / 2.0)


func _style(bg: Color, border: Color, radius: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	return s


func _panel(parent: Control, rect: Rect2, bg: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.position = rect.position
	p.size = rect.size
	p.custom_minimum_size = rect.size
	p.add_theme_stylebox_override("panel", _style(bg, COLOR_LINE))
	parent.add_child(p)
	return p


func _margin(parent: Node, child: Control, h: int, v: int) -> void:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", h)
	m.add_theme_constant_override("margin_right", h)
	m.add_theme_constant_override("margin_top", v)
	m.add_theme_constant_override("margin_bottom", v)
	m.mouse_filter = Control.MOUSE_FILTER_PASS
	parent.add_child(m)
	m.add_child(child)


func _label(parent: Node, text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if parent:
		parent.add_child(l)
	return l


func _header(parent: Node, text: String) -> void:
	var l := _label(parent, text.to_upper(), 11, COLOR_DIM.darkened(0.1))
	l.add_theme_constant_override("outline_size", 0)


func _button(parent: Node, text: String, font_size: int) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", font_size)
	parent.add_child(b)
	return b


func _separator(parent: Node) -> void:
	var s := VSeparator.new()
	s.add_theme_color_override("color", COLOR_LINE)
	parent.add_child(s)


# --- Mises à jour appelées par Main ------------------------------------------------------------

func set_tower_types(towers: Array[TowerData]) -> void:
	_towers = towers
	for b in _build_buttons:
		b.queue_free()
	_build_buttons.clear()
	for i in towers.size():
		var t := towers[i]
		var b := _button(_base_row if t.element == Element.Type.NONE else _corruption_row, "", 12)
		b.custom_minimum_size = BUTTON_SIZE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.clip_text = true
		b.add_theme_color_override("font_color", Element.color(t.element).lerp(COLOR_TEXT, 0.25))
		b.add_theme_color_override("font_disabled_color", Element.color(t.element).darkened(0.55))
		b.pressed.connect(build_requested.emit.bind(i))
		b.mouse_entered.connect(func() -> void:
			_hovered_button = i
			_show_info(tower_info(t)))
		b.mouse_exited.connect(func() -> void:
			_hovered_button = -1
			_show_info(_map_info))
		_build_buttons.append(b)


func set_build_selection(index: int) -> void:
	for i in _build_buttons.size():
		_build_buttons[i].set_pressed_no_signal(i == index)


## `unlocked[i]` : la tour i est disponible (corruption débloquée).
func set_gold(gold: int, towers: Array[TowerData], unlocked: Array[bool]) -> void:
	_gold_label.text = "Or %d" % gold
	for i in mini(towers.size(), _build_buttons.size()):
		var t := towers[i]
		_build_buttons[i].disabled = t.cost > gold or not unlocked[i]
		_build_buttons[i].text = "%d %s %s" % [i + 1, t.display_name, str(t.cost) if unlocked[i] else "—"]


## Stigmates restants et corruptions débloquées (Element.Type -> true).
func set_elements(essences: int, owned: Dictionary, can_buy: bool) -> void:
	_stigma_label.text = "Stigmates %d" % essences + (" · clique sur la roue" if essences > 0 and can_buy and owned.size() < Element.ALL.size() else "")
	_element_wheel.set_state(owned, essences > 0 and can_buy)


func set_lives(lives: int) -> void:
	_lives_label.text = "Vies %d" % lives


## `spawning` : la vague `number` est en train d'apparaître ; sinon `number` est la prochaine,
## lancée automatiquement dans `seconds_left` secondes (ou plus tôt, contre `early_bonus` or).
func set_wave(number: int, total: int, preview: String, spawning: bool, seconds_left: float, early_bonus: int) -> void:
	if spawning:
		_wave_label.text = "Vague %d/%d en cours · %s" % [number, total, preview]
		_start_button.text = "Vague en cours"
	elif number <= total:
		_wave_label.text = "Vague %d/%d dans %d s · %s" % [number, total, ceili(seconds_left), preview]
		_start_button.text = "Lancer (Espace) +%d or" % early_bonus
	else:
		_wave_label.text = "Toutes les vagues sont lancées"
		_start_button.text = "Dernière vague"
	_start_button.disabled = spawning or number > total


## Prochaines vagues : liste de { number, text, color } (couleur de la corruption, gris si neutre).
func set_upcoming(waves: Array) -> void:
	if waves == _last_upcoming and _upcoming_box.get_child_count() > 0:
		return
	_last_upcoming = waves.duplicate(true)
	for c in _upcoming_box.get_children():
		c.queue_free()
	if waves.is_empty():
		_label(_upcoming_box, "Plus de vague à venir", 13, COLOR_DIM)
		return
	for w in waves:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _style(Color(0.11, 0.105, 0.1), Color(0, 0, 0, 0), 4))
		var rows := VBoxContainer.new()
		rows.add_theme_constant_override("separation", 3)
		_margin(row, rows, 6, 3)
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 6)
		rows.add_child(line)
		_label(line, str(w.number), 12, COLOR_DIM)
		var dot := ColorRect.new()
		dot.color = w.color
		dot.custom_minimum_size = Vector2(10, 10)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(dot)
		var text := _label(line, w.text, 12, COLOR_TEXT)
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if w.get("stigma", false):
			var stigma := _label(line, "+1 stigmate", 11, COLOR_STIGMA)
			stigma.tooltip_text = "Vaincre cette vague donne un stigmate"
			stigma.mouse_filter = Control.MOUSE_FILTER_PASS
		if w.get("elite", false):
			_add_elite_choice(rows, w)
		_upcoming_box.add_child(row)


## Ligne « Élites » d'une vague : 6 pastilles pour choisir leur corruption (avant le lancement),
## et le stigmate promis si on les tue tous.
func _add_elite_choice(parent: Control, w: Dictionary) -> void:
	var chosen: Element.Type = w.elite_choice
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 3)
	parent.add_child(line)
	if w.choosable:
		_label(line, "Élites :", 11, COLOR_DIM)
		for element in Element.ALL:
			var b := Button.new()
			b.focus_mode = Control.FOCUS_NONE
			b.custom_minimum_size = Vector2(18, 16)
			var col := Element.color(element)
			var selected: bool = element == chosen
			b.add_theme_stylebox_override("normal", _style(col if selected else col.darkened(0.55), Color.WHITE if selected else col.darkened(0.2), 3))
			b.add_theme_stylebox_override("hover", _style(col, Color.WHITE, 3))
			b.add_theme_stylebox_override("pressed", _style(col, Color.WHITE, 3))
			b.tooltip_text = "Appeler des élites de %s : les tuer tous donne un stigmate de %s" % [Element.display_name(element), Element.display_name(element)]
			var index: int = w.index
			b.pressed.connect(func() -> void: elite_chosen.emit(index, element))
			line.add_child(b)
	var hint := "stigmate de %s" % Element.display_name(chosen) if chosen != Element.Type.NONE else "à choisir (sinon hasard)"
	_label(line if not w.choosable else parent, ("Élites : " if not w.choosable else "→ ") + hint, 11,
			Element.color(chosen) if chosen != Element.Type.NONE else COLOR_DIM)


func set_speed(multiplier: float) -> void:
	_speed_button.text = "×%d (F)" % int(multiplier)


func setup_minimap(board: Board, camera: Camera2D, main: Node) -> void:
	_minimap.setup(board, camera, main)


## Infos de ce qu'on survole sur la carte (texte BBCode). Vide : rappel des commandes de base.
func set_info(text: String) -> void:
	_map_info = text
	if _hovered_button < 0:
		_show_info(text)


func _show_info(text: String) -> void:
	if text == "":
		text = "[b]Infos[/b]\nSurvole une tour, un bouton, une ruine ou une terre corrompue pour voir son détail ici.\nH : aide"
	_info_label.text = text


## Fiche d'une tour pour le panneau d'infos.
static func tower_info(t: TowerData) -> String:
	var text := "[b][color=#%s]%s[/color] · %d or[/b]\n%s" % [
		Element.color(t.element).to_html(false), t.display_name, t.cost, t.description]
	if t.branches.size() >= 2:
		text += "\nBranches : %s / %s" % [t.branches[0].display_name, t.branches[1].display_name]
	return text


func toggle_help() -> void:
	_help_panel.visible = not _help_panel.visible


func is_help_visible() -> bool:
	return _help_panel.visible


func show_selection(tower: Tower) -> void:
	var has := tower != null
	_selection_title.visible = has
	_selection_stats.visible = has
	_upgrade_button.visible = has
	_sell_button.visible = has
	_selection_hint.visible = not has
	_upgrade_button_alt.visible = false
	if not has:
		return
	var d := tower.data
	_selection_title.text = "%s niv. %d" % [d.display_name, tower.level]
	if tower.chosen_branch():
		_selection_title.text += " · " + tower.chosen_branch().display_name
	if tower.is_upgrading():
		_selection_title.text = "%s → niv. %d : %d %%" % [d.display_name, tower.level, roundi(tower.build_progress * 100.0)]
	elif not tower.is_built():
		_selection_title.text = "%s — chantier %d %%" % [d.display_name, roundi(tower.build_progress * 100.0)]
	_selection_title.add_theme_color_override("font_color", Element.color(d.element).lerp(COLOR_TEXT, 0.15))
	var first := "Dégâts %.0f · %.1f tirs/s · portée %.1f" % [tower.damage(), tower.fire_rate(), tower.attack_range() / 40.0]
	var extra: PackedStringArray = []
	if tower.splash_radius() > 0.0:
		extra.append("zone %.0f px" % tower.splash_radius())
	if tower.chain_count() > 0:
		extra.append("%d rebonds" % tower.chain_count())
	if tower.slow_factor() < 1.0:
		extra.append("ralentit %d %% (%.1f s)" % [roundi((1.0 - tower.slow_factor()) * 100.0), d.slow_duration])
	if d.poison_dps > 0.0:
		extra.append("poison %.0f/s · %.0f s" % [tower.poison_dps(), d.poison_duration])
	if tower.terrain != Element.Type.NONE:
		var m := tower.terrain_multiplier()
		var effect := "sans effet" if is_equal_approx(m, 1.0) else "%+d %%" % roundi((m - 1.0) * 100.0)
		extra.append("terre de %s : %s" % [Element.display_name(tower.terrain), effect])
	_selection_stats.text = first + ("\n" + " · ".join(extra) if not extra.is_empty() else "")
	_upgrade_button.tooltip_text = ""
	if not tower.is_built():
		_upgrade_button.text = "En chantier"
		_upgrade_button.disabled = true
	elif not tower.can_upgrade():
		_upgrade_button.text = "Niveau max"
		_upgrade_button.disabled = true
	elif tower.needs_branch_choice():
		# Niveau 1 : choisir une des deux branches de l'arbre
		var branches := d.branches
		_upgrade_button.text = "U : %s %d" % [branches[0].display_name, tower.upgrade_cost()]
		_upgrade_button.tooltip_text = branches[0].description
		_upgrade_button.disabled = false
		if branches.size() > 1:
			_upgrade_button_alt.visible = true
			_upgrade_button_alt.text = "I : %s %d" % [branches[1].display_name, tower.upgrade_cost()]
			_upgrade_button_alt.tooltip_text = branches[1].description
			_upgrade_button_alt.disabled = false
	else:
		var b := tower.chosen_branch()
		var label := "%s niv. %d" % [b.display_name, tower.level + 1] if b else "Améliorer"
		_upgrade_button.text = "U : %s %d" % [label, tower.upgrade_cost()]
		_upgrade_button.tooltip_text = b.description if b else ""
		_upgrade_button.disabled = false
	_sell_button.text = ("V : vendre +%d" if tower.is_built() or tower.is_upgrading() else "V : annuler +%d") % tower.sell_value()


func set_upgrade_affordable(affordable: bool) -> void:
	if _upgrade_button.text != "Niveau max" and _upgrade_button.text != "En chantier":
		_upgrade_button.disabled = not affordable
		_upgrade_button_alt.disabled = not affordable


## Texte qui s'affiche quelques secondes en haut de la zone de jeu, puis s'efface.
func announce(text: String, seconds: float = 5.0) -> void:
	_announce_label.text = text
	_announce_label.visible = true
	_announce_label.modulate.a = 1.0
	if _announce_tween:
		_announce_tween.kill()
	_announce_tween = create_tween()
	_announce_tween.tween_interval(seconds)
	_announce_tween.tween_property(_announce_label, "modulate:a", 0.0, 1.0)
	_announce_tween.tween_callback(func() -> void: _announce_label.visible = false)


func announcement() -> String:
	return _announce_label.text if _announce_label.visible else ""


func show_message(text: String) -> void:
	_message_label.text = text
	_message_panel.visible = text != ""
