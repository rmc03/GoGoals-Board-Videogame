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
	_create_options_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if options_menu and options_menu.is_open():
			options_menu.hide_menu()
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
	var text: String = "[center][b]🏆 MEJORES JUGADORES 🏆[/b][/center]\n\n"
	
	if leaderboard.is_empty():
		text += "[center]¡Aún no hay registros![/center]"
	else:
		text += "Pos | Turnos | Tiempo | Nombre\n"
		text += "--------------------------------------------------------\n"
		
		for i in range(leaderboard.size()):
			var record: Dictionary = leaderboard[i]
			var minutes: int = floor(record.time / 60.0)
			var float_seconds: float = fmod(record.time, 60.0)
			var time_str: String = "%02d:%05.2f" % [minutes, float_seconds]
			
			text += "%3d | %6d | %7s | %s\n" % [i + 1, record.turns, time_str, record.name]

	ranking_lbl.text = text

func _create_options_menu() -> void:
	options_menu = MenuOptionsUIScript.new()
	options_menu.name = "MenuOptionsUI"
	add_child(options_menu)
	options_menu.setup(self)
