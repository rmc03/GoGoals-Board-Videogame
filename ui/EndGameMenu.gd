extends Control

var final_time: float = 0.0
var final_turns: int = 0
var winner_index: int = -1
var final_summary: Dictionary = {}

@onready var panel: Panel = $Panel
@onready var title_lbl: Label = $Panel/Label
@onready var stats_lbl: Label = $Panel/LabelStats
@onready var input_name: LineEdit = $Panel/InputName
@onready var submit_btn: Button = $Panel/ButtonSubmit
@onready var menu_btn: Button = $Panel/ButtonMenu
@onready var restart_btn: Button = $Panel/ButtonRestart

var details_lbl: RichTextLabel

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_overlay()
	_style_panel()
	_layout_panel()
	_build_details_label()
	_connect_buttons()
	_populate_summary()
	input_name.placeholder_text = "Nombre del ganador"
	input_name.grab_focus()

func _build_overlay() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.02, 0.05, 0.68)
	add_child(overlay)
	move_child(overlay, 0)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.1, 0.16, 0.98)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.62, 1.0, 0.6)
	style.shadow_size = 14
	style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", style)

	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0))
	stats_lbl.add_theme_font_size_override("font_size", 18)
	stats_lbl.add_theme_color_override("font_color", Color(0.82, 0.89, 1.0))
	input_name.add_theme_font_size_override("font_size", 18)

func _layout_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	panel.size = Vector2(760, 480)
	panel.position = (viewport_size - panel.size) / 2.0

	title_lbl.position = Vector2(250, 18)
	title_lbl.size = Vector2(260, 32)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	stats_lbl.position = Vector2(36, 62)
	stats_lbl.size = Vector2(688, 82)

	input_name.position = Vector2(36, 366)
	input_name.size = Vector2(688, 40)

	submit_btn.position = Vector2(36, 416)
	submit_btn.size = Vector2(220, 40)

	restart_btn.position = Vector2(274, 416)
	restart_btn.size = Vector2(180, 40)

	menu_btn.position = Vector2(472, 416)
	menu_btn.size = Vector2(252, 40)

func _build_details_label() -> void:
	details_lbl = RichTextLabel.new()
	details_lbl.position = Vector2(36, 154)
	details_lbl.size = Vector2(688, 196)
	details_lbl.bbcode_enabled = true
	details_lbl.fit_content = false
	details_lbl.scroll_active = false
	details_lbl.add_theme_font_size_override("normal_font_size", 16)
	panel.add_child(details_lbl)

func _connect_buttons() -> void:
	submit_btn.pressed.connect(_on_submit_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)

func _populate_summary() -> void:
	var minutes: int = floor(final_time / 60.0)
	var seconds: float = fmod(final_time, 60.0)
	var time_str: String = "%02d:%05.2f" % [minutes, seconds]
	var winner_text: String = "Jugador %d" % [winner_index + 1] if winner_index >= 0 else "Ganador"
	var accuracy: float = float(final_summary.get("accuracy", 0.0))
	var quizzes_answered: int = int(final_summary.get("quizzes_answered", 0))
	var correct_answers: int = int(final_summary.get("correct_answers", 0))

	title_lbl.text = "Fin del juego"
	stats_lbl.text = "%s logro la meta.\nTiempo: %s   |   Turnos: %d   |   Precision: %.0f%%" % [winner_text, time_str, final_turns, accuracy]

	var details_text: String = "[b]Resumen de partida[/b]\n"
	details_text += "Preguntas respondidas: %d\n" % quizzes_answered
	details_text += "Aciertos / fallos: %d / %d\n" % [correct_answers, int(final_summary.get("incorrect_answers", 0))]
	details_text += "Mejor racha: %d\n" % int(final_summary.get("best_streak", 0))
	details_text += "Casillas especiales activadas: %d\n" % int(final_summary.get("special_tiles_triggered", 0))
	details_text += "Escaleras / bajadas: %d / %d\n" % [int(final_summary.get("ladders_taken", 0)), int(final_summary.get("slides_taken", 0))]
	details_text += "ODS visitados (%d): %s\n" % [int(final_summary.get("unique_ods_count", 0)), _format_ods_list(final_summary.get("unique_ods", []))]
	details_text += "Pausas usadas: %d\n" % int(final_summary.get("pause_count", 0))
	details_text += "Turnos por jugador: %s" % _format_turns(final_summary.get("player_turns", []))
	details_lbl.text = details_text

func _format_ods_list(ods_values: Array) -> String:
	if ods_values.is_empty():
		return "Ninguno"

	var labels: Array[String] = []
	for ods_id in ods_values:
		labels.append("ODS %02d" % int(ods_id))
	return ", ".join(labels)

func _format_turns(turn_values: Array) -> String:
	if turn_values.is_empty():
		return "Sin datos"

	var labels: Array[String] = []
	for i in range(turn_values.size()):
		labels.append("J%d=%d" % [i + 1, int(turn_values[i])])
	return " | ".join(labels)

func _on_submit_pressed() -> void:
	if input_name.text.strip_edges().length() <= 0:
		submit_btn.text = "Introduce un nombre valido"
		return

	var player_name: String = input_name.text.strip_edges()
	var success: bool = RecordsManager.submit_new_record(player_name, final_time, final_turns)
	submit_btn.disabled = true
	submit_btn.text = "Guardado" if success else "No mejora el record"

func _on_menu_pressed() -> void:
	AudioManager.stop_music()
	get_tree().change_scene_to_file(Constants.SCENE_MENU_PRINCIPAL)

func _on_restart_pressed() -> void:
	AudioManager.stop_music()
	get_tree().reload_current_scene()
