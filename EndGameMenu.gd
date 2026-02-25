# EndGameMenu.gd
extends Control

# Variables que se deben pasar al cargar la escena
var final_time: float
var final_turns: int

@onready var stats_lbl = $Panel/LabelStats
@onready var input_name = $Panel/InputName
@onready var submit_btn = $Panel/ButtonSubmit
@onready var menu_btn = $Panel/ButtonMenu
@onready var restart_btn = $Panel/ButtonRestart

func _ready():
	# Conexiones
	submit_btn.pressed.connect(_on_submit_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	
	# Mostrar estadísticas
	var minutes = floor(final_time / 60)
	var seconds = fmod(final_time, 60)
	var time_str = "%02d:%05.2f" % [minutes, seconds]
	
	stats_lbl.text = "¡Lo lograste!\nTu tiempo: %s\nTurnos: %d" % [time_str, final_turns]

func _on_submit_pressed():
	if input_name.text.strip_edges().length() > 0:
		# CAMBIO AQUÍ: Usamos player_name en vez de name
		var player_name = input_name.text.strip_edges()
		
		# Pasamos player_name a la función
		var success = RecordsManager.submit_new_record(player_name, final_time, final_turns)
		
		submit_btn.disabled = true
		submit_btn.text = "¡Guardado!" if success else "No mejoró el récord"
	else:
		submit_btn.text = "Introduce un nombre válido"
		
func _on_menu_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn") # Ajusta la ruta

func _on_restart_pressed():
	# Recarga la escena de juego actual
	get_tree().reload_current_scene()
