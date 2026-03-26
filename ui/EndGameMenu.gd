extends Control

var final_time: float = 0.0
var final_turns: int = 0
var winner_index: int = -1
var final_summary: Dictionary = {}

@onready var panel: Panel = $Center/Panel
@onready var title_icon: Label = $Center/Panel/Margin/Content/HeaderRow/TitleIcon
@onready var title_lbl: Label = $Center/Panel/Margin/Content/HeaderRow/Label
@onready var stats_lbl: Label = $Center/Panel/Margin/Content/LabelStats
@onready var time_value: Label = $Center/Panel/Margin/Content/HighlightsRow/CardTime/CardTimeBox/CardTimeValue
@onready var turns_value: Label = $Center/Panel/Margin/Content/HighlightsRow/CardTurns/CardTurnsBox/CardTurnsValue
@onready var accuracy_value: Label = $Center/Panel/Margin/Content/HighlightsRow/CardAccuracy/CardAccuracyBox/CardAccuracyValue
@onready var questions_value: Label = $Center/Panel/Margin/Content/HighlightsRow/CardQuestions/CardQuestionsBox/CardQuestionsValue
@onready var details_panel: Panel = $Center/Panel/Margin/Content/DetailsPanel
@onready var details_lbl: RichTextLabel = $Center/Panel/Margin/Content/DetailsPanel/DetailsMargin/DetailsScroll/DetailsLabel
@onready var input_name: LineEdit = $Center/Panel/Margin/Content/NameBox/InputName
@onready var submit_btn: Button = $Center/Panel/Margin/Content/ButtonsRow/ButtonSubmit
@onready var menu_btn: Button = $Center/Panel/Margin/Content/ButtonsRow/ButtonMenu
@onready var restart_btn: Button = $Center/Panel/Margin/Content/ButtonsRow/ButtonRestart

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_overlay()
	_style_panel()
	_layout_panel()
	_connect_buttons()
	_populate_summary()
	input_name.placeholder_text = "Nombre del ganador"
	input_name.grab_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_panel()

func _build_overlay() -> void:
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.02, 0.05, 0.68)
	add_child(overlay)
	move_child(overlay, 0)

func _style_panel() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.1, 0.16, 0.98)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_left = 26
	style.corner_radius_bottom_right = 26
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.62, 1.0, 0.6)
	style.shadow_size = 18
	style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", style)

	var content: VBoxContainer = $Center/Panel/Margin/Content
	content.add_theme_constant_override("separation", 12)
	$Center/Panel/Margin.add_theme_constant_override("margin_left", 26)
	$Center/Panel/Margin.add_theme_constant_override("margin_right", 26)
	$Center/Panel/Margin.add_theme_constant_override("margin_top", 22)
	$Center/Panel/Margin.add_theme_constant_override("margin_bottom", 22)

	var header_row: HBoxContainer = $Center/Panel/Margin/Content/HeaderRow
	header_row.add_theme_constant_override("separation", 10)
	title_icon.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_font_size_override("font_size", 28)
	title_lbl.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0))

	stats_lbl.add_theme_font_size_override("font_size", 18)
	stats_lbl.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0))
	stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_style_card($Center/Panel/Margin/Content/HighlightsRow/CardTime)
	_style_card($Center/Panel/Margin/Content/HighlightsRow/CardTurns)
	_style_card($Center/Panel/Margin/Content/HighlightsRow/CardAccuracy)
	_style_card($Center/Panel/Margin/Content/HighlightsRow/CardQuestions)

	var highlights: HBoxContainer = $Center/Panel/Margin/Content/HighlightsRow
	highlights.add_theme_constant_override("separation", 10)

	_style_card_text($Center/Panel/Margin/Content/HighlightsRow/CardTime/CardTimeBox)
	_style_card_text($Center/Panel/Margin/Content/HighlightsRow/CardTurns/CardTurnsBox)
	_style_card_text($Center/Panel/Margin/Content/HighlightsRow/CardAccuracy/CardAccuracyBox)
	_style_card_text($Center/Panel/Margin/Content/HighlightsRow/CardQuestions/CardQuestionsBox)

	var details_title: Label = $Center/Panel/Margin/Content/DetailsTitle
	details_title.add_theme_font_size_override("font_size", 16)
	details_title.add_theme_color_override("font_color", Color(0.78, 0.86, 0.98))

	var details_style: StyleBoxFlat = StyleBoxFlat.new()
	details_style.bg_color = Color(0.05, 0.08, 0.14, 0.85)
	details_style.corner_radius_top_left = 18
	details_style.corner_radius_top_right = 18
	details_style.corner_radius_bottom_left = 18
	details_style.corner_radius_bottom_right = 18
	details_style.border_width_left = 1
	details_style.border_width_right = 1
	details_style.border_width_top = 1
	details_style.border_width_bottom = 1
	details_style.border_color = Color(0.25, 0.42, 0.7, 0.6)
	details_panel.add_theme_stylebox_override("panel", details_style)

	var details_margin: MarginContainer = $Center/Panel/Margin/Content/DetailsPanel/DetailsMargin
	details_margin.add_theme_constant_override("margin_left", 14)
	details_margin.add_theme_constant_override("margin_right", 14)
	details_margin.add_theme_constant_override("margin_top", 10)
	details_margin.add_theme_constant_override("margin_bottom", 10)

	details_lbl.bbcode_enabled = true
	details_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_lbl.add_theme_font_size_override("normal_font_size", 15)
	details_lbl.add_theme_color_override("default_color", Color(0.85, 0.9, 1.0))
	details_lbl.fit_content = false
	details_lbl.scroll_active = false

	var name_title: Label = $Center/Panel/Margin/Content/NameBox/NameLabel
	name_title.add_theme_font_size_override("font_size", 15)
	name_title.add_theme_color_override("font_color", Color(0.8, 0.88, 1.0))

	input_name.add_theme_font_size_override("font_size", 18)
	_style_line_edit(input_name)

	_style_primary_button(submit_btn)
	_style_secondary_button(restart_btn)
	_style_secondary_button(menu_btn)

	var buttons_row: HBoxContainer = $Center/Panel/Margin/Content/ButtonsRow
	buttons_row.add_theme_constant_override("separation", 10)
	submit_btn.custom_minimum_size = Vector2(0, 44)
	restart_btn.custom_minimum_size = Vector2(0, 44)
	menu_btn.custom_minimum_size = Vector2(0, 44)

func _layout_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var target_width: float = clamp(viewport_size.x * 0.75, 700.0, 980.0)
	var target_height: float = clamp(viewport_size.y * 0.82, 520.0, 700.0)
	panel.custom_minimum_size = Vector2(target_width, target_height)

func _style_card(card: Panel) -> void:
	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = Color(0.06, 0.1, 0.18, 0.92)
	card_style.corner_radius_top_left = 16
	card_style.corner_radius_top_right = 16
	card_style.corner_radius_bottom_left = 16
	card_style.corner_radius_bottom_right = 16
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(0.25, 0.5, 0.85, 0.7)
	card.add_theme_stylebox_override("panel", card_style)

func _style_card_text(box: VBoxContainer) -> void:
	box.add_theme_constant_override("separation", 2)
	for child in box.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	box.get_child(0).add_theme_font_size_override("font_size", 12)
	box.get_child(1).add_theme_font_size_override("font_size", 20)

func _style_line_edit(line: LineEdit) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.12, 0.2, 0.95)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_width_top = 1
	normal.border_width_bottom = 1
	normal.border_color = Color(0.35, 0.55, 0.85, 0.8)
	line.add_theme_stylebox_override("normal", normal)
	line.add_theme_stylebox_override("focus", normal)
	line.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	line.add_theme_color_override("placeholder_color", Color(0.6, 0.7, 0.85))

func _style_primary_button(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.52, 0.92)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_bottom = 3
	normal.border_color = Color(0.12, 0.3, 0.6)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.22, 0.6, 1.0)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(0.12, 0.4, 0.75)
	pressed.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)

func _style_secondary_button(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.16, 0.2, 0.3)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_bottom = 2
	normal.border_color = Color(0.35, 0.45, 0.65)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.22, 0.28, 0.4)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(0.1, 0.14, 0.22)
	pressed.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))

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

	title_lbl.text = "Fin de la partida"
	stats_lbl.text = "%s logro la meta. Aqui tienes el resumen final." % winner_text
	time_value.text = time_str
	turns_value.text = str(final_turns)
	accuracy_value.text = "%d%%" % int(round(accuracy))
	questions_value.text = str(quizzes_answered)

	var details_text: String = "Preguntas respondidas: %d\n" % quizzes_answered
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
