extends Control

const MenuOptionsUIScript := preload("res://scripts/UI/Menu/OptionsMenu.gd")

@onready var btn_jugar: Button = $ButtonJugar
@onready var btn_ranking: Button = $ButtonRanking
@onready var btn_salir: Button = $ButtonSalir
@onready var btn_options: Button = $ButtonOptions

@onready var panel_seleccion: Panel = $PanelSeleccion
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
	
	btn_cancelar_sel.pressed.connect(func(): panel_seleccion.visible = false)
	
	btn_cerrar_ranking.pressed.connect(_on_cerrar_ranking_pressed)
	
	ventana_ranking.visible = false
	panel_seleccion.visible = false
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
			panel_seleccion.visible = false
			get_viewport().set_input_as_handled()

# --- EVENTS ---

func _on_jugar_pressed() -> void:
	panel_seleccion.visible = true

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
		panel_seleccion.visible = false
		ventana_ranking.visible = false
		options_menu.show_menu()

# --- UTILS ---

func display_leaderboard() -> void:
	var leaderboard: Array = RecordsManager.get_leaderboard() 
	var text: String = "[center][b]🏆 RANKING 🏆[/b][/center]\n\n"
	
	if leaderboard.is_empty():
		text += "[center]Aún no hay registros.[/center]"
	else:
		text += "[table=4]"
		text += "[cell][b]# [/b][/cell]"
		text += "[cell][b]Turnos[/b][/cell]"
		text += "[cell][b]Tiempo[/b][/cell]"
		text += "[cell][b]Jugador[/b][/cell]"
		
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
			
			text += "[cell]%d%s[/cell]" % [i + 1, medal]
			text += "[cell]%d[/cell]" % record_turns
			text += "[cell]%s[/cell]" % time_str
			text += "[cell]%s[/cell]" % record_name

		text += "[/table]"

	ranking_lbl.text = text

func _style_menu() -> void:
	_style_menu_button(btn_jugar, Color(0.18, 0.48, 0.78))
	_style_menu_button(btn_como_jugar, Color(0.14, 0.32, 0.55))
	_style_menu_button(btn_ranking, Color(0.14, 0.32, 0.55))
	_style_menu_button(btn_options, Color(0.12, 0.26, 0.48))
	_style_menu_button(btn_salir, Color(0.55, 0.18, 0.2))

	_apply_panel_style(panel_seleccion)
	_apply_panel_style(ventana_ranking)

	ranking_lbl.scroll_active = true
	ranking_lbl.fit_content = true
	ranking_lbl.add_theme_font_size_override("font_size", 16)
	ranking_lbl.add_theme_color_override("default_color", Color(0.92, 0.96, 1.0))

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

func _create_options_menu() -> void:
	options_menu = MenuOptionsUIScript.new()
	options_menu.name = "MenuOptionsUI"
	add_child(options_menu)
	options_menu.setup(self)
