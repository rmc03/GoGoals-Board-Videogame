extends Node
class_name QuizPanelUI

var panel: Panel
var question_label: Label
var option_buttons: Array[Button] = []
var current_question_data: Dictionary = {}
var current_player: int = 0
var current_ods_id: int = 0

signal answer_selected(answer_result: Dictionary)

func setup(target_panel: Panel, target_label: Label, buttons: Array[Button]) -> void:
	panel = target_panel
	question_label = target_label
	option_buttons = buttons

	_style_panel()
	_connect_buttons()
	_reset_panel()

func _connect_buttons() -> void:
	for i in range(option_buttons.size()):
		var button: Button = option_buttons[i]
		if button == null:
			continue

		var callback: Callable = Callable(self, "_on_option_selected").bind(i)
		if not button.pressed.is_connected(callback):
			button.pressed.connect(callback)

func _style_panel() -> void:
	var quiz_style: StyleBoxFlat = StyleBoxFlat.new()
	quiz_style.bg_color = Color(0.06, 0.1, 0.2, 0.96)
	quiz_style.corner_radius_top_left = 20
	quiz_style.corner_radius_top_right = 20
	quiz_style.corner_radius_bottom_left = 20
	quiz_style.corner_radius_bottom_right = 20
	quiz_style.border_width_left = 3
	quiz_style.border_width_right = 3
	quiz_style.border_width_top = 3
	quiz_style.border_width_bottom = 3
	quiz_style.border_color = Color(0.3, 0.7, 1.0, 0.7)
	quiz_style.shadow_color = Color(0, 0, 0, 0.7)
	quiz_style.shadow_size = 15
	panel.add_theme_stylebox_override("panel", quiz_style)

	question_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	question_label.add_theme_font_size_override("font_size", 24)
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	for button in option_buttons:
		if button:
			_style_button(button)

func _style_button(button: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.25, 0.45)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.3, 0.5, 0.8, 0.5)
	normal.content_margin_left = 15
	normal.content_margin_right = 15
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.18, 0.4, 0.7)
	hover.border_color = Color(0.4, 0.7, 1.0, 0.9)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(0.08, 0.2, 0.4)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 0.85))

func _set_button_feedback(button: Button, base_color: Color) -> void:
	if button == null:
		return

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = base_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = base_color.lightened(0.18)
	style.content_margin_left = 15
	style.content_margin_right = 15
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)

func _reset_button_visuals() -> void:
	for button in option_buttons:
		if button:
			button.modulate = Color.WHITE
			_style_button(button)

func show_question(question_data: Dictionary, player_index: int, ods_id: int) -> void:
	current_question_data = question_data.duplicate(true)
	current_player = player_index
	current_ods_id = ods_id
	_reset_button_visuals()

	question_label.text = "ODS %02d  |  Pregunta para J%d\n\n%s" % [ods_id, player_index + 1, current_question_data.get("q", "")]

	var options: Array = current_question_data.get("options", [])
	for i in range(option_buttons.size()):
		var button: Button = option_buttons[i]
		if button == null:
			continue

		if i < options.size():
			button.text = "%s)  %s" % [["A", "B", "C"][i], options[i]]
			button.visible = true
			button.disabled = false
		else:
			button.visible = false

	panel.modulate = Color(1, 1, 1, 0)
	panel.scale = Vector2(0.9, 0.9)
	panel.pivot_offset = panel.size / 2.0
	panel.show()

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(panel, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)

	for button in option_buttons:
		if button and button.visible:
			button.grab_focus()
			break

func _on_option_selected(option_index: int) -> void:
	if current_question_data.is_empty():
		return

	set_enabled(false)
	var correct_index: int = int(current_question_data.get("correct", -1))
	var is_correct: bool = option_index == correct_index
	var result_data: Dictionary = {
		"is_correct": is_correct,
		"selected_index": option_index,
		"correct_index": correct_index,
		"selected_text": option_buttons[option_index].text if option_index < option_buttons.size() else "",
		"correct_text": str(current_question_data.get("correct_text", "")),
		"explanation": str(current_question_data.get("explanation", "")),
		"ods_id": current_ods_id,
		"question": str(current_question_data.get("q", ""))
	}
	await _show_answer_feedback(option_index, correct_index, result_data)
	await hide_panel()
	answer_selected.emit(result_data)

func _show_answer_feedback(selected_index: int, correct_index: int, result_data: Dictionary) -> void:
	if selected_index >= 0 and selected_index < option_buttons.size():
		var selected_button: Button = option_buttons[selected_index]
		if result_data.get("is_correct", false):
			_set_button_feedback(selected_button, Color(0.18, 0.48, 0.26))
		else:
			_set_button_feedback(selected_button, Color(0.55, 0.18, 0.2))

	if correct_index >= 0 and correct_index < option_buttons.size():
		_set_button_feedback(option_buttons[correct_index], Color(0.18, 0.48, 0.26))

	var status_title: String = "Respuesta correcta" if result_data.get("is_correct", false) else "Respuesta incorrecta"
	var correct_text: String = str(result_data.get("correct_text", ""))
	var explanation: String = str(result_data.get("explanation", "")).strip_edges()
	question_label.text = "%s\n\n%s" % [status_title, current_question_data.get("q", "")]
	if not correct_text.is_empty():
		question_label.text += "\n\nCorrecta: %s" % correct_text
	if not explanation.is_empty():
		question_label.text += "\n%s" % explanation

	await get_tree().create_timer(1.8).timeout

func hide_panel() -> void:
	if panel == null or not panel.visible:
		_reset_panel()
		return

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_property(panel, "scale", Vector2(0.95, 0.95), 0.2)
	await tween.finished
	_reset_panel()

func _reset_panel() -> void:
	current_question_data.clear()
	current_player = 0
	current_ods_id = 0
	_reset_button_visuals()
	if panel:
		panel.hide()
		panel.scale = Vector2.ONE
		panel.modulate = Color.WHITE

func set_enabled(enabled: bool) -> void:
	for button in option_buttons:
		if button:
			button.disabled = not enabled
