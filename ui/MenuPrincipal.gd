extends Control

const MenuOptionsUIScript := preload("res://scripts/UI/Menu/OptionsMenu.gd")
const DEBUG_SEED_RANKING := true
const DISPLAY_FONT := preload("res://Assets/Fonts/adventure-request/Adventure ReQuest.otf")

@onready var btn_jugar: Button = $ButtonJugar
@onready var btn_ranking: Button = $ButtonRanking
@onready var btn_salir: Button = $ButtonSalir
@onready var btn_options: Button = $ButtonOptions
@onready var panel_seleccion: Panel = $PanelSeleccion
@onready var selection_title_label: Label = $PanelSeleccion/Label
@onready var btn_1p: Button = $PanelSeleccion/Btn1P
@onready var btn_2p: Button = $PanelSeleccion/Btn2P
@onready var btn_3p: Button = $PanelSeleccion/Btn3P
@onready var btn_4p: Button = $PanelSeleccion/Btn4P
@onready var btn_cancelar_sel: Button = $PanelSeleccion/BtnCancelar
@onready var btn_como_jugar: Button = $ButtonComoJugar

@onready var ventana_ranking: Panel = $VentanaRanking
@onready var ranking_lbl: RichTextLabel = $VentanaRanking/LabelRanking
@onready var btn_cerrar_ranking: Button = $VentanaRanking/BotonCerrar

var options_menu: MenuOptionsUI
var ranking_root: Control
var ranking_rows: VBoxContainer
var ranking_empty_label: Label
var ranking_scroll: ScrollContainer
var selection_overlay: ColorRect
var selection_subtitle_label: Label
var selection_hint_label: Label

func _ready() -> void:
	btn_jugar.pressed.connect(_on_jugar_pressed)
	btn_ranking.pressed.connect(_on_ranking_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_como_jugar.pressed.connect(_on_como_jugar_pressed)
	btn_options.pressed.connect(_on_options_pressed)
	
	btn_1p.pressed.connect(_on_players_selected.bind(1))
	btn_2p.pressed.connect(_on_players_selected.bind(2))
	btn_3p.pressed.connect(_on_players_selected.bind(3))
	btn_4p.pressed.connect(_on_players_selected.bind(4))
	
	btn_cancelar_sel.pressed.connect(func(): _set_selection_visible(false))
	
	btn_cerrar_ranking.pressed.connect(_on_cerrar_ranking_pressed)
	
	ventana_ranking.visible = false
	_set_selection_visible(false)
	_style_menu()
	_create_options_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if options_menu and options_menu.is_open():
			options_menu.hide_menu()
			get_viewport().set_input_as_handled()
		elif ventana_ranking.visible:
			ventana_ranking.visible = false
			get_viewport().set_input_as_handled()
		elif panel_seleccion.visible:
			_set_selection_visible(false)
			get_viewport().set_input_as_handled()

# --- EVENTS ---

func _on_jugar_pressed() -> void:
	_set_selection_visible(true)

func _on_players_selected(cantidad: int) -> void:
	GameData.players_count = cantidad
	get_tree().change_scene_to_file("res://scenes/pantalla_de_juego.tscn")

func _on_ranking_pressed() -> void:
	display_leaderboard()
	ventana_ranking.visible = true
	
func _on_cerrar_ranking_pressed() -> void:
	ventana_ranking.visible = false
 
func _on_como_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/ComoJugar.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_options_pressed() -> void:
	if options_menu:
		_set_selection_visible(false)
		ventana_ranking.visible = false
		options_menu.show_menu()

# --- UTILS ---

func display_leaderboard() -> void:
	if DEBUG_SEED_RANKING and OS.is_debug_build():
		if RecordsManager.get_leaderboard().is_empty():
			RecordsManager.debug_seed_records()

	var leaderboard: Array = RecordsManager.get_leaderboard()
	_ensure_ranking_ui()

	if ranking_rows == null:
		return

	for child in ranking_rows.get_children():
		child.queue_free()
	ranking_empty_label = null

	if leaderboard.is_empty():
		ranking_empty_label = Label.new()
		ranking_empty_label.text = "Aún no hay registros."
		ranking_empty_label.add_theme_font_size_override("font_size", 16)
		ranking_empty_label.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
		ranking_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ranking_empty_label.custom_minimum_size = Vector2(0, 60)
		ranking_rows.add_child(ranking_empty_label)
		return

	for i in range(leaderboard.size()):
		var record: Dictionary = leaderboard[i]
		var record_time: float = float(record.get("time", 0.0))
		var record_turns: int = int(record.get("turns", 0))
		var record_name: String = str(record.get("name", "Anónimo")).strip_edges()
		if record_name.is_empty():
			record_name = "Anónimo"

		var minutes: int = floor(record_time / 60.0)
		var float_seconds: float = fmod(record_time, 60.0)
		var time_str: String = "%02d:%05.2f" % [minutes, float_seconds]

		var medal: String = ""
		if i == 0:
			medal = " 🥇"
		elif i == 1:
			medal = " 🥈"
		elif i == 2:
			medal = " 🥉"

		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _row_style(i))
		row_panel.custom_minimum_size = Vector2(0, 34)
		ranking_rows.add_child(row_panel)

		var row_margin := MarginContainer.new()
		row_margin.anchor_right = 1.0
		row_margin.anchor_bottom = 1.0
		row_margin.offset_left = 10.0
		row_margin.offset_top = 6.0
		row_margin.offset_right = -10.0
		row_margin.offset_bottom = -6.0
		row_panel.add_child(row_margin)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row_margin.add_child(row)

		row.add_child(_make_cell("%d%s" % [i + 1, medal], 52, HORIZONTAL_ALIGNMENT_CENTER, true))
		row.add_child(_make_cell(str(record_turns), 86, HORIZONTAL_ALIGNMENT_CENTER))
		row.add_child(_make_cell(time_str, 110, HORIZONTAL_ALIGNMENT_CENTER))
		row.add_child(_make_cell(record_name, 0, HORIZONTAL_ALIGNMENT_LEFT))

func _style_menu() -> void:
	_style_menu_button(btn_jugar, Color(0.18, 0.48, 0.78))
	_style_menu_button(btn_como_jugar, Color(0.14, 0.32, 0.55))
	_style_menu_button(btn_ranking, Color(0.14, 0.32, 0.55))
	_style_menu_button(btn_options, Color(0.12, 0.26, 0.48))
	_style_menu_button(btn_salir, Color(0.55, 0.18, 0.2))
	_setup_selection_modal()
	_apply_panel_style(ventana_ranking)
	_center_ranking_panel()
	_style_close_button(btn_cerrar_ranking)
	_ensure_ranking_ui()

func _style_menu_button(button: Button, base_color: Color) -> void:
	if button == null:
		return

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 3
	normal.border_color = base_color.lightened(0.2)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = base_color.lightened(0.12)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = base_color.darkened(0.12)
	pressed.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_override("font", DISPLAY_FONT)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 0.9))

func _apply_panel_style(panel: Panel) -> void:
	if panel == null:
		return
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.1, 0.16, 0.94)
	panel_style.corner_radius_top_left = 18
	panel_style.corner_radius_top_right = 18
	panel_style.corner_radius_bottom_left = 18
	panel_style.corner_radius_bottom_right = 18
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.35, 0.6, 1.0, 0.6)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	panel_style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", panel_style)

func _center_ranking_panel() -> void:
	if ventana_ranking == null:
		return
	ventana_ranking.anchor_left = 0.5
	ventana_ranking.anchor_right = 0.5
	ventana_ranking.anchor_top = 0.5
	ventana_ranking.anchor_bottom = 0.5
	ventana_ranking.offset_left = -270.0
	ventana_ranking.offset_right = 270.0
	ventana_ranking.offset_top = -300.0
	ventana_ranking.offset_bottom = 300.0

func _style_close_button(button: Button) -> void:
	if button == null:
		return
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.anchor_top = 0.0
	button.anchor_bottom = 0.0
	button.offset_left = -40.0
	button.offset_right = -8.0
	button.offset_top = 8.0
	button.offset_bottom = 40.0

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.25, 0.35)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 2
	normal.border_color = Color(0.5, 0.65, 0.9, 0.6)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.28, 0.34, 0.5)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(0.16, 0.2, 0.32)
	pressed.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

func _ensure_ranking_ui() -> void:
	if ventana_ranking == null:
		return
	if ranking_root != null:
		return

	if ranking_lbl:
		ranking_lbl.visible = false

	ranking_root = MarginContainer.new()
	ranking_root.name = "RankingRoot"
	ranking_root.anchor_right = 1.0
	ranking_root.anchor_bottom = 1.0
	ranking_root.offset_left = 18.0
	ranking_root.offset_top = 18.0
	ranking_root.offset_right = -18.0
	ranking_root.offset_bottom = -18.0
	ventana_ranking.add_child(ranking_root)

	var vbox := VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.add_theme_constant_override("separation", 10)
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ranking_root.add_child(vbox)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 6)
	vbox.add_child(title_row)

	var title := Label.new()
	title.text = "🏆 RANKING"
	title.add_theme_font_override("font", DISPLAY_FONT)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_row.add_child(title)

	var header_panel := PanelContainer.new()
	header_panel.add_theme_stylebox_override("panel", _header_style())
	vbox.add_child(header_panel)

	var header_margin := MarginContainer.new()
	header_margin.anchor_right = 1.0
	header_margin.anchor_bottom = 1.0
	header_margin.offset_left = 10.0
	header_margin.offset_top = 6.0
	header_margin.offset_right = -10.0
	header_margin.offset_bottom = -6.0
	header_panel.add_child(header_margin)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header_margin.add_child(header)

	header.add_child(_make_header_cell("#", 44))
	header.add_child(_make_header_cell("Turnos", 86))
	header.add_child(_make_header_cell("Tiempo", 110))
	header.add_child(_make_header_cell("Jugador", 0))

	var list_panel := PanelContainer.new()
	list_panel.add_theme_stylebox_override("panel", _list_style())
	list_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_panel.custom_minimum_size = Vector2(0, 260)
	vbox.add_child(list_panel)

	var list_margin := MarginContainer.new()
	list_margin.anchor_right = 1.0
	list_margin.anchor_bottom = 1.0
	list_margin.offset_left = 8.0
	list_margin.offset_top = 8.0
	list_margin.offset_right = -8.0
	list_margin.offset_bottom = -8.0
	list_panel.add_child(list_margin)

	ranking_scroll = ScrollContainer.new()
	ranking_scroll.anchor_right = 1.0
	ranking_scroll.anchor_bottom = 1.0
	ranking_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ranking_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ranking_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	list_margin.add_child(ranking_scroll)

	ranking_rows = VBoxContainer.new()
	ranking_rows.anchor_right = 1.0
	ranking_rows.anchor_bottom = 1.0
	ranking_rows.add_theme_constant_override("separation", 8)
	ranking_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_rows.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	ranking_rows.custom_minimum_size = Vector2(0, 0)
	ranking_scroll.add_child(ranking_rows)

	ranking_empty_label = Label.new()
	ranking_empty_label.text = "Aún no hay registros."
	ranking_empty_label.add_theme_font_size_override("font_size", 18)
	ranking_empty_label.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
	ranking_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ranking_empty_label.custom_minimum_size = Vector2(0, 80)
	ranking_rows.add_child(ranking_empty_label)

func _make_header_cell(text: String, width: float) -> Control:
	return _make_cell(text, width, HORIZONTAL_ALIGNMENT_CENTER, true, true)

func _make_cell(text: String, width: float, align: int, bold: bool = false, header: bool = false) -> Control:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if width <= 0.0 else Control.SIZE_SHRINK_CENTER
	if width > 0.0:
		label.custom_minimum_size = Vector2(width, 0)
	var font_size: int = 16 if not header else 15
	label.add_theme_font_size_override("font_size", font_size)
	if bold:
		label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
	else:
		label.add_theme_color_override("font_color", Color(0.86, 0.9, 0.96))
	return label

func _header_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.18, 0.28)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.35, 0.55, 0.9, 0.7)
	return style

func _list_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.1, 0.16, 0.75)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.28, 0.45, 0.75, 0.5)
	return style

func _row_style(index: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var base := Color(0.1, 0.15, 0.24, 0.65)
	var alt := Color(0.13, 0.18, 0.28, 0.75)
	style.bg_color = alt if index % 2 == 0 else base
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.22, 0.35, 0.55, 0.4)
	return style

func _create_options_menu() -> void:
	options_menu = MenuOptionsUIScript.new()
	options_menu.name = "MenuOptionsUI"
	add_child(options_menu)
	options_menu.setup(self)

func _setup_selection_modal() -> void:
	if panel_seleccion == null:
		return

	_ensure_selection_overlay()
	panel_seleccion.mouse_filter = Control.MOUSE_FILTER_STOP
	_center_selection_panel()
	_apply_selection_panel_style(panel_seleccion)
	_style_selection_close_button(btn_cancelar_sel)

	if panel_seleccion.get_node_or_null("ModalContent") != null:
		return

	var margin := MarginContainer.new()
	margin.name = "ModalContent"
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 26.0
	margin.offset_top = 24.0
	margin.offset_right = -26.0
	margin.offset_bottom = -24.0
	panel_seleccion.add_child(margin)

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 0.0
	content.offset_top = 0.0
	content.offset_right = 0.0
	content.offset_bottom = 0.0
	content.add_theme_constant_override("separation", 16)
	margin.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	content.add_child(header)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 4)
	header.add_child(title_box)

	selection_title_label.reparent(title_box)
	selection_title_label.text = "Elige la partida"
	selection_title_label.add_theme_font_override("font", DISPLAY_FONT)
	selection_title_label.add_theme_font_size_override("font_size", 30)
	selection_title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))

	selection_subtitle_label = Label.new()
	selection_subtitle_label.text = "Selecciona cuántos jugadores participarán en esta aventura."
	selection_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_subtitle_label.add_theme_font_size_override("font_size", 15)
	selection_subtitle_label.add_theme_color_override("font_color", Color(0.71, 0.8, 0.9))
	title_box.add_child(selection_subtitle_label)

	btn_cancelar_sel.reparent(header)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)

	btn_1p.reparent(grid)
	_configure_player_button(btn_1p, "1 jugador", "Partida individual\nPara aprender el tablero.", Color(0.22, 0.56, 0.78))

	btn_2p.reparent(grid)
	_configure_player_button(btn_2p, "2 jugadores", "Modo recomendado\nEquilibrado y competitivo.", Color(0.23, 0.6, 0.44))

	btn_3p.reparent(grid)
	_configure_player_button(btn_3p, "3 jugadores", "Más rotación\nPartida más dinámica.", Color(0.77, 0.53, 0.18))

	btn_4p.reparent(grid)
	_configure_player_button(btn_4p, "4 jugadores", "Modo completo\nIdeal para jugar en grupo.", Color(0.72, 0.32, 0.48))

	selection_hint_label = Label.new()
	selection_hint_label.text = "Todos juegan en la misma pantalla y avanzan por turnos."
	selection_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_hint_label.add_theme_font_size_override("font_size", 14)
	selection_hint_label.add_theme_color_override("font_color", Color(0.64, 0.72, 0.83))
	content.add_child(selection_hint_label)

func _ensure_selection_overlay() -> void:
	if selection_overlay != null:
		return

	selection_overlay = ColorRect.new()
	selection_overlay.name = "SelectionOverlay"
	selection_overlay.anchor_right = 1.0
	selection_overlay.anchor_bottom = 1.0
	selection_overlay.color = Color(0.01, 0.03, 0.08, 0.58)
	selection_overlay.visible = false
	selection_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	selection_overlay.z_index = 20
	panel_seleccion.z_index = 21
	add_child(selection_overlay)
	move_child(selection_overlay, panel_seleccion.get_index())
	selection_overlay.gui_input.connect(_on_selection_overlay_input)

func _on_selection_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_selection_visible(false)

func _set_selection_visible(visible: bool) -> void:
	if panel_seleccion:
		panel_seleccion.visible = visible
	if selection_overlay:
		selection_overlay.visible = visible
	if visible and btn_2p:
		btn_2p.grab_focus()

func _center_selection_panel() -> void:
	if panel_seleccion == null:
		return
	panel_seleccion.anchor_left = 0.5
	panel_seleccion.anchor_right = 0.5
	panel_seleccion.anchor_top = 0.5
	panel_seleccion.anchor_bottom = 0.5
	panel_seleccion.offset_left = -280.0
	panel_seleccion.offset_right = 280.0
	panel_seleccion.offset_top = -210.0
	panel_seleccion.offset_bottom = 210.0

func _apply_selection_panel_style(panel: Panel) -> void:
	if panel == null:
		return
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.1, 0.16, 0.96)
	panel_style.corner_radius_top_left = 22
	panel_style.corner_radius_top_right = 22
	panel_style.corner_radius_bottom_left = 22
	panel_style.corner_radius_bottom_right = 22
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.44, 0.68, 0.97, 0.42)
	panel_style.shadow_color = Color(0, 0, 0, 0.4)
	panel_style.shadow_size = 14
	panel.add_theme_stylebox_override("panel", panel_style)

func _configure_player_button(button: Button, title: String, description: String, accent: Color) -> void:
	button.text = ""
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 118)
	button.focus_mode = Control.FOCUS_NONE
	_style_selection_option_button(button, accent)

	for child in button.get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 16.0
	margin.offset_top = 14.0
	margin.offset_right = -16.0
	margin.offset_bottom = -14.0
	button.add_child(margin)

	var content := VBoxContainer.new()
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_left = 0.0
	content.offset_top = 0.0
	content.offset_right = 0.0
	content.offset_bottom = 0.0
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var title_label := Label.new()
	title_label.text = title
	title_label.custom_minimum_size = Vector2(0, 36)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_override("font", DISPLAY_FONT)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(title_label)

	var description_label := Label.new()
	description_label.text = description
	description_label.custom_minimum_size = Vector2(0, 42)
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.add_theme_color_override("font_color", Color(0.72, 0.8, 0.9))
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(description_label)

func _style_selection_option_button(button: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.09, 0.14, 0.22, 0.94)
	normal.corner_radius_top_left = 18
	normal.corner_radius_top_right = 18
	normal.corner_radius_bottom_left = 18
	normal.corner_radius_bottom_right = 18
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.border_color = accent
	normal.content_margin_left = 0
	normal.content_margin_right = 0
	normal.content_margin_top = 0
	normal.content_margin_bottom = 0

	var hover := normal.duplicate()
	hover.bg_color = Color(0.12, 0.19, 0.3, 0.98)
	hover.border_color = accent.lightened(0.15)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.07, 0.12, 0.19, 0.98)
	pressed.border_color = accent.darkened(0.1)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)

func _style_selection_close_button(button: Button) -> void:
	if button == null:
		return

	button.custom_minimum_size = Vector2(40, 40)
	button.focus_mode = Control.FOCUS_NONE

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.06)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.border_color = Color(1, 1, 1, 0.12)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.86, 0.23, 0.31, 0.2)
	hover.border_color = Color(0.95, 0.46, 0.5, 0.35)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.75, 0.17, 0.25, 0.22)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
