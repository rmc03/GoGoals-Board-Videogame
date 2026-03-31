extends Node
class_name GameHUD

const HUD_ACCENT_FONT: FontFile = preload("res://Assets/Fonts/ticketing/TICKETING/Ticketing.ttf")
const PLAYER_COLORS: Array[Color] = [
	Color(0.6, 0.2, 0.8),
	Color(0.9, 0.2, 0.2),
	Color(0.2, 0.7, 0.3),
	Color(0.2, 0.5, 0.9)
]

var hud_host: Node
var legacy_timer_label: Label
var legacy_turn_label: Label
var legacy_result_label: Label
var dice_button: Button
var game_manager: GameManager

var stats_panel: Panel
var dice_panel: Panel
var timer_display: Label
var turn_display: Label
var dice_result_label: Label
var feedback_label: Label
var pause_button: Button
var dice_base_text: String = ""
var dice_text_before_pause: String = ""
var player_chip_label: Label
var turn_chip_label: Label

signal dice_requested()
signal pause_requested()

func setup(host: Node, button: Button, timer_label: Label, turn_label: Label, result_label: Label, manager: GameManager) -> void:
	hud_host = host
	dice_button = button
	if dice_button:
		dice_base_text = dice_button.text
	legacy_timer_label = timer_label
	legacy_turn_label = turn_label
	legacy_result_label = result_label
	game_manager = manager

	_hide_legacy_labels()
	_build_hud()
	_connect_button()
	_bind_manager()
	set_dice_enabled(true)
	update_timer(0.0)

func _hide_legacy_labels() -> void:
	if legacy_timer_label:
		legacy_timer_label.visible = false
	if legacy_turn_label:
		legacy_turn_label.visible = false
	if legacy_result_label:
		legacy_result_label.visible = false

func _build_hud() -> void:
	var edge_margin := 18.0
	var stats_width := 280.0
	var stats_height := 162.0

	stats_panel = Panel.new()
	stats_panel.anchor_left = 1.0
	stats_panel.anchor_right = 1.0
	stats_panel.anchor_top = 0.0
	stats_panel.anchor_bottom = 0.0
	stats_panel.clip_contents = true
	stats_panel.offset_left = -(stats_width + edge_margin)
	stats_panel.offset_top = edge_margin
	stats_panel.offset_right = -edge_margin
	stats_panel.offset_bottom = stats_height + edge_margin
	_apply_stats_panel_style(stats_panel)
	hud_host.add_child(stats_panel)

	var stats_margin := MarginContainer.new()
	stats_margin.anchor_right = 1.0
	stats_margin.anchor_bottom = 1.0
	stats_margin.offset_left = 14.0
	stats_margin.offset_top = 14.0
	stats_margin.offset_right = -14.0
	stats_margin.offset_bottom = -14.0
	stats_panel.add_child(stats_margin)

	var stats_box := VBoxContainer.new()
	stats_box.anchor_right = 1.0
	stats_box.anchor_bottom = 1.0
	stats_box.offset_left = 0.0
	stats_box.offset_top = 0.0
	stats_box.offset_right = 0.0
	stats_box.offset_bottom = 0.0
	stats_box.add_theme_constant_override("separation", 8)
	stats_margin.add_child(stats_box)

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 10)
	stats_box.add_child(header_row)

	timer_display = Label.new()
	timer_display.text = "Tiempo 00:00.00"
	timer_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_display.add_theme_font_override("font", HUD_ACCENT_FONT)
	timer_display.add_theme_font_size_override("font_size", 18)
	timer_display.add_theme_color_override("font_color", Color(0.96, 0.97, 0.99))
	header_row.add_child(timer_display)

	pause_button = Button.new()
	pause_button.text = "Pausa"
	pause_button.custom_minimum_size = Vector2(88, 30)
	_style_pause_button()
	header_row.add_child(pause_button)

	var info_row := HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 6)
	stats_box.add_child(info_row)

	player_chip_label = Label.new()
	player_chip_label.text = "Jugador 1"
	player_chip_label.add_theme_font_size_override("font_size", 14)
	player_chip_label.add_theme_color_override("font_color", Color(0.83, 0.76, 0.98))
	info_row.add_child(player_chip_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_child(spacer)

	turn_chip_label = Label.new()
	turn_chip_label.text = "Tirada #0"
	turn_chip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	turn_chip_label.add_theme_font_size_override("font_size", 13)
	turn_chip_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.84))
	info_row.add_child(turn_chip_label)

	turn_display = Label.new()
	turn_display.text = _default_status_text()
	turn_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	turn_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	turn_display.add_theme_font_size_override("font_size", 12)
	turn_display.add_theme_color_override("font_color", Color(0.64, 0.71, 0.76))
	stats_box.add_child(turn_display)

	feedback_label = turn_display
	dice_panel = stats_panel

	var button_inset := MarginContainer.new()
	button_inset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_inset.add_theme_constant_override("margin_left", 0)
	button_inset.add_theme_constant_override("margin_top", 2)
	button_inset.add_theme_constant_override("margin_right", 0)
	button_inset.add_theme_constant_override("margin_bottom", 0)
	stats_box.add_child(button_inset)

	dice_button.reparent(button_inset)
	dice_button.custom_minimum_size = Vector2(0, 42)
	dice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dice_button.add_theme_constant_override("icon_max_width", 24)
	dice_button.add_theme_constant_override("h_separation", 12)
	_style_dice_button()

func _apply_panel_style(panel: Panel, bg: Color, border: Color) -> void:
	var hud_style: StyleBoxFlat = StyleBoxFlat.new()
	hud_style.bg_color = bg
	hud_style.corner_radius_top_left = 16
	hud_style.corner_radius_top_right = 16
	hud_style.corner_radius_bottom_left = 16
	hud_style.corner_radius_bottom_right = 16
	hud_style.border_width_left = 2
	hud_style.border_width_right = 2
	hud_style.border_width_top = 2
	hud_style.border_width_bottom = 2
	hud_style.border_color = border
	hud_style.shadow_color = Color(0, 0, 0, 0.4)
	hud_style.shadow_size = 6
	panel.add_theme_stylebox_override("panel", hud_style)

func _apply_stats_panel_style(panel: Panel) -> void:
	var hud_style: StyleBoxFlat = StyleBoxFlat.new()
	hud_style.bg_color = Color(0.08, 0.11, 0.14, 0.9)
	hud_style.corner_radius_top_left = 16
	hud_style.corner_radius_top_right = 16
	hud_style.corner_radius_bottom_left = 16
	hud_style.corner_radius_bottom_right = 16
	hud_style.border_width_left = 1
	hud_style.border_width_right = 1
	hud_style.border_width_top = 1
	hud_style.border_width_bottom = 1
	hud_style.border_color = Color(1, 1, 1, 0.18)
	hud_style.shadow_color = Color(0, 0, 0, 0)
	hud_style.shadow_size = 0
	panel.add_theme_stylebox_override("panel", hud_style)

func _create_info_chip(text: String, bg: Color, border: Color, font_color: Color, font_size: int) -> Dictionary:
	var panel_chip := PanelContainer.new()
	panel_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var chip_style := StyleBoxFlat.new()
	chip_style.bg_color = bg
	chip_style.corner_radius_top_left = 12
	chip_style.corner_radius_top_right = 12
	chip_style.corner_radius_bottom_left = 12
	chip_style.corner_radius_bottom_right = 12
	chip_style.border_width_left = 1
	chip_style.border_width_right = 1
	chip_style.border_width_top = 1
	chip_style.border_width_bottom = 1
	chip_style.border_color = border
	chip_style.content_margin_left = 9
	chip_style.content_margin_right = 9
	chip_style.content_margin_top = 5
	chip_style.content_margin_bottom = 5
	panel_chip.add_theme_stylebox_override("panel", chip_style)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	panel_chip.add_child(label)
	return {"panel": panel_chip, "label": label}

func _style_dice_button() -> void:
	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.22, 0.53, 0.42)
	btn_normal.corner_radius_top_left = 10
	btn_normal.corner_radius_top_right = 10
	btn_normal.corner_radius_bottom_left = 10
	btn_normal.corner_radius_bottom_right = 10
	btn_normal.border_width_left = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color(1, 1, 1, 0.12)
	btn_normal.shadow_color = Color(0, 0, 0, 0)
	btn_normal.shadow_size = 0
	btn_normal.content_margin_left = 12
	btn_normal.content_margin_right = 12
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8

	var btn_hover: StyleBoxFlat = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.26, 0.6, 0.47)

	var btn_pressed: StyleBoxFlat = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.18, 0.44, 0.35)

	var btn_disabled: StyleBoxFlat = btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.24, 0.28, 0.31)
	btn_disabled.border_color = Color(1, 1, 1, 0.08)

	dice_button.add_theme_stylebox_override("normal", btn_normal)
	dice_button.add_theme_stylebox_override("hover", btn_hover)
	dice_button.add_theme_stylebox_override("pressed", btn_pressed)
	dice_button.add_theme_stylebox_override("disabled", btn_disabled)
	dice_button.add_theme_font_size_override("font_size", 18)
	dice_button.add_theme_color_override("font_color", Color.WHITE)
	dice_button.add_theme_color_override("font_hover_color", Color.WHITE)
	dice_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))

func _style_pause_button() -> void:
	var pause_normal: StyleBoxFlat = StyleBoxFlat.new()
	pause_normal.bg_color = Color(1, 1, 1, 0.04)
	pause_normal.corner_radius_top_left = 10
	pause_normal.corner_radius_top_right = 10
	pause_normal.corner_radius_bottom_left = 10
	pause_normal.corner_radius_bottom_right = 10
	pause_normal.border_width_left = 1
	pause_normal.border_width_right = 1
	pause_normal.border_width_top = 1
	pause_normal.border_width_bottom = 1
	pause_normal.border_color = Color(1, 1, 1, 0.16)

	var pause_hover: StyleBoxFlat = pause_normal.duplicate()
	pause_hover.bg_color = Color(1, 1, 1, 0.08)

	var pause_pressed: StyleBoxFlat = pause_normal.duplicate()
	pause_pressed.bg_color = Color(1, 1, 1, 0.02)

	pause_button.add_theme_stylebox_override("normal", pause_normal)
	pause_button.add_theme_stylebox_override("hover", pause_hover)
	pause_button.add_theme_stylebox_override("pressed", pause_pressed)
	pause_button.add_theme_font_size_override("font_size", 13)
	pause_button.add_theme_color_override("font_color", Color(0.9, 0.94, 0.98))

func _connect_button() -> void:
	if dice_button and not dice_button.pressed.is_connected(_on_dice_pressed):
		dice_button.pressed.connect(_on_dice_pressed)
	if pause_button and not pause_button.pressed.is_connected(_on_pause_pressed):
		pause_button.pressed.connect(_on_pause_pressed)

func _bind_manager() -> void:
	game_manager.turn_started.connect(_on_turn_started)
	game_manager.dice_rolled.connect(_on_dice_rolled)
	game_manager.feedback_requested.connect(show_feedback)
	game_manager.game_time_updated.connect(update_timer)
	game_manager.input_state_changed.connect(set_dice_enabled)
	game_manager.victory.connect(_on_victory)
	game_manager.pause_state_changed.connect(_on_pause_state_changed)

func _on_dice_pressed() -> void:
	dice_requested.emit()

func _on_pause_pressed() -> void:
	pause_requested.emit()

func _on_turn_started(player_index: int, turn_count: int) -> void:
	var color: Color = PLAYER_COLORS[player_index % PLAYER_COLORS.size()]
	if player_chip_label:
		player_chip_label.text = "Jugador %d" % [player_index + 1]
		player_chip_label.add_theme_color_override("font_color", color.lightened(0.18))
	if turn_chip_label:
		turn_chip_label.text = "Tirada #%d" % [turn_count]
	turn_display.text = _default_status_text()
	turn_display.add_theme_color_override("font_color", Color(0.64, 0.71, 0.76))

func _on_dice_rolled(_player_index: int, value: int) -> void:
	_animate_dice_roll(value)

func _on_victory(_player_index: int, _time: float, _turns: int) -> void:
	if dice_button:
		dice_button.text = "🏆 ¡Victoria!"
	set_dice_enabled(false)
	if pause_button:
		pause_button.disabled = true

func _on_pause_state_changed(paused: bool) -> void:
	if pause_button:
		pause_button.text = "Reanudar" if paused else "Pausa"
	if dice_button:
		if paused:
			dice_text_before_pause = dice_button.text
			dice_button.text = "⏸ Pausado"
		elif not dice_text_before_pause.is_empty():
			dice_button.text = dice_text_before_pause
			dice_text_before_pause = ""

func update_timer(time: float) -> void:
	var minutes: int = floor(time / 60.0)
	var seconds: float = fmod(time, 60.0)
	timer_display.text = "Tiempo  %02d:%05.2f" % [minutes, seconds]

func show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate = Color(1, 1, 1, 0)

	var tween: Tween = create_tween()
	tween.tween_property(feedback_label, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_interval(1.8)
	tween.tween_property(feedback_label, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func():
		feedback_label.text = _default_status_text()
		feedback_label.add_theme_color_override("font_color", Color(0.64, 0.71, 0.76))
		feedback_label.modulate = Color.WHITE
	)

func set_dice_enabled(enabled: bool) -> void:
	if dice_button:
		dice_button.disabled = not enabled
		if enabled:
			dice_button.text = dice_base_text

func set_quiz_active(active: bool) -> void:
	var visible_state := not active
	if stats_panel:
		stats_panel.visible = visible_state
	if dice_panel:
		dice_panel.visible = visible_state

func _animate_dice_roll(final_value: int) -> void:
	var dice_faces: Array[String] = ["⚀", "⚁", "⚂", "⚃", "⚄", "⚅"]
	var tween: Tween = create_tween()

	for _i in range(8):
		var random_face: String = dice_faces[randi() % dice_faces.size()]
		tween.tween_callback(func(): dice_button.text = random_face + " ...")
		tween.tween_interval(0.06)

	tween.tween_callback(func():
		dice_button.text = dice_faces[final_value - 1] + "  ¡" + str(final_value) + "!"
		dice_button.add_theme_font_size_override("font_size", 18)
	)
	tween.tween_interval(0.15)
	tween.tween_callback(func():
		dice_button.add_theme_font_size_override("font_size", 17)
	)

func _default_status_text() -> String:
	return "Tira para avanzar."
