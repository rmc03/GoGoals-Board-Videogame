extends Control

var final_time: float
var final_turns: int

@onready var stats_lbl: Label = $Panel/LabelStats
@onready var input_name: LineEdit = $Panel/InputName
@onready var submit_btn: Button = $Panel/ButtonSubmit
@onready var menu_btn: Button = $Panel/ButtonMenu
@onready var restart_btn: Button = $Panel/ButtonRestart

func _ready() -> void:
	submit_btn.pressed.connect(_on_submit_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	
	var minutes: int = floor(final_time / 60.0)
	var seconds: float = fmod(final_time, 60.0)
	var time_str: String = "%02d:%05.2f" % [minutes, seconds]
	
	stats_lbl.text = "¡Lo lograste!\nTu tiempo: %s\nTurnos: %d" % [time_str, final_turns]

func _on_submit_pressed() -> void:
	if input_name.text.strip_edges().length() > 0:
		var player_name: String = input_name.text.strip_edges()
		
		var success: bool = RecordsManager.submit_new_record(player_name, final_time, final_turns)
		
		submit_btn.disabled = true
		submit_btn.text = "¡Guardado!" if success else "No mejoró el récord"
	else:
		submit_btn.text = "Introduce un nombre válido"
		
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/MenuPrincipal.tscn")

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
