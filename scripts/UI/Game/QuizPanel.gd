extends Node
class_name QuizPanelUI

var panel: Panel
var question_label: Label
var option_buttons: Array[Button] = []
var current_question_data: Dictionary = {}
var current_player: int = 0
var current_ods_id: int = 0

signal answer_selected(is_correct: bool)

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

func show_question(question_data: Dictionary, player_index: int, ods_id: int) -> void:
	current_question_data = question_data.duplicate(true)
	current_player = player_index
	current_ods_id = ods_id

	question_label.text = "📝 Pregunta para J%d:\n\n%s" % [player_index + 1, current_question_data.get("q", "")]

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

func _on_option_selected(option_index: int) -> void:
	if current_question_data.is_empty():
		return

	set_enabled(false)
	var correct_index: int = int(current_question_data.get("correct", -1))
	var is_correct: bool = option_index == correct_index
	await hide_panel()
	answer_selected.emit(is_correct)

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
	if panel:
		panel.hide()
		panel.scale = Vector2.ONE
		panel.modulate = Color.WHITE

func set_enabled(enabled: bool) -> void:
	for button in option_buttons:
		if button:
			button.disabled = not enabled
