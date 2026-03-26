extends Node
class_name GameHUD

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
	var stats_width := 220.0
	var stats_height := 200.0
	var dice_width := 260.0
	var dice_height := 160.0

	stats_panel = Panel.new()
	stats_panel.anchor_left = 1.0
	stats_panel.anchor_right = 1.0
	stats_panel.anchor_top = 0.0
	stats_panel.anchor_bottom = 0.0
	stats_panel.offset_left = -(stats_width + edge_margin)
	stats_panel.offset_top = edge_margin
	stats_panel.offset_right = -edge_margin
	stats_panel.offset_bottom = stats_height + edge_margin
	_apply_panel_style(stats_panel, Color(0.05, 0.08, 0.15, 0.9), Color(0.3, 0.6, 1.0, 0.6))
	hud_host.add_child(stats_panel)

	var stats_margin := MarginContainer.new()
	stats_margin.anchor_right = 1.0
	stats_margin.anchor_bottom = 1.0
	stats_margin.offset_left = 12.0
	stats_margin.offset_top = 10.0
	stats_margin.offset_right = -12.0
	stats_margin.offset_bottom = -10.0
	stats_panel.add_child(stats_margin)

	var stats_box := VBoxContainer.new()
	stats_box.anchor_right = 1.0
	stats_box.anchor_bottom = 1.0
	stats_box.offset_left = 0.0
	stats_box.offset_top = 0.0
	stats_box.offset_right = 0.0
	stats_box.offset_bottom = 0.0
	stats_box.add_theme_constant_override("separation", 6)
	stats_margin.add_child(stats_box)

	timer_display = Label.new()
	timer_display.text = "⏱ 00:00.00"
	timer_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_display.add_theme_font_size_override("font_size", 17)
	timer_display.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	stats_box.add_child(timer_display)

	pause_button = Button.new()
	pause_button.text = "Pausa"
	pause_button.custom_minimum_size = Vector2(0, 28)
	pause_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_pause_button()
	stats_box.add_child(pause_button)

	turn_display = Label.new()
	turn_display.text = ""
	turn_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	turn_display.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	turn_display.add_theme_font_size_override("font_size", 14)
	turn_display.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	stats_box.add_child(turn_display)

	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_font_size_override("font_size", 13)
	feedback_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	stats_box.add_child(feedback_label)

	dice_panel = Panel.new()
	dice_panel.anchor_left = 1.0
	dice_panel.anchor_right = 1.0
	dice_panel.anchor_top = 1.0
	dice_panel.anchor_bottom = 1.0
	dice_panel.offset_left = -(dice_width + edge_margin)
	dice_panel.offset_top = -(dice_height + edge_margin)
	dice_panel.offset_right = -edge_margin
	dice_panel.offset_bottom = -edge_margin
	_apply_panel_style(dice_panel, Color(0.06, 0.12, 0.22, 0.92), Color(0.4, 0.75, 1.0, 0.7))
	hud_host.add_child(dice_panel)

	var dice_margin := MarginContainer.new()
	dice_margin.anchor_right = 1.0
	dice_margin.anchor_bottom = 1.0
	dice_margin.offset_left = 14.0
	dice_margin.offset_top = 12.0
	dice_margin.offset_right = -14.0
	dice_margin.offset_bottom = -12.0
	dice_panel.add_child(dice_margin)

	var dice_box := VBoxContainer.new()
	dice_box.anchor_right = 1.0
	dice_box.anchor_bottom = 1.0
	dice_box.offset_left = 0.0
	dice_box.offset_top = 0.0
	dice_box.offset_right = 0.0
	dice_box.offset_bottom = 0.0
	dice_box.add_theme_constant_override("separation", 6)
	dice_margin.add_child(dice_box)

	dice_button.reparent(dice_box)
	dice_button.custom_minimum_size = Vector2(0, 56)
	dice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

func _style_dice_button() -> void:
	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.15, 0.45, 0.85)
	btn_normal.corner_radius_top_left = 12
	btn_normal.corner_radius_top_right = 12
	btn_normal.corner_radius_bottom_left = 12
	btn_normal.corner_radius_bottom_right = 12
	btn_normal.border_width_bottom = 0
	btn_normal.border_color = Color(0, 0, 0, 0)

	var btn_hover: StyleBoxFlat = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.55, 0.95)

	var btn_pressed: StyleBoxFlat = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.1, 0.35, 0.7)
	btn_pressed.border_width_bottom = 0

	var btn_disabled: StyleBoxFlat = btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.25, 0.25, 0.3)
	btn_disabled.border_color = Color(0.2, 0.2, 0.25)

	dice_button.add_theme_stylebox_override("normal", btn_normal)
	dice_button.add_theme_stylebox_override("hover", btn_hover)
	dice_button.add_theme_stylebox_override("pressed", btn_pressed)
	dice_button.add_theme_stylebox_override("disabled", btn_disabled)
	dice_button.add_theme_font_size_override("font_size", 20)
	dice_button.add_theme_color_override("font_color", Color.WHITE)
	dice_button.add_theme_color_override("font_hover_color", Color(1, 1, 0.8))
	dice_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))

func _style_pause_button() -> void:
	var pause_normal: StyleBoxFlat = StyleBoxFlat.new()
	pause_normal.bg_color = Color(0.18, 0.22, 0.32)
	pause_normal.corner_radius_top_left = 10
	pause_normal.corner_radius_top_right = 10
	pause_normal.corner_radius_bottom_left = 10
	pause_normal.corner_radius_bottom_right = 10
	pause_normal.border_width_left = 1
	pause_normal.border_width_right = 1
	pause_normal.border_width_top = 1
	pause_normal.border_width_bottom = 2
	pause_normal.border_color = Color(0.45, 0.55, 0.75)

	var pause_hover: StyleBoxFlat = pause_normal.duplicate()
	pause_hover.bg_color = Color(0.24, 0.3, 0.42)

	var pause_pressed: StyleBoxFlat = pause_normal.duplicate()
	pause_pressed.bg_color = Color(0.12, 0.16, 0.24)
	pause_pressed.border_width_bottom = 1

	pause_button.add_theme_stylebox_override("normal", pause_normal)
	pause_button.add_theme_stylebox_override("hover", pause_hover)
	pause_button.add_theme_stylebox_override("pressed", pause_pressed)
	pause_button.add_theme_font_size_override("font_size", 14)
	pause_button.add_theme_color_override("font_color", Color(0.93, 0.95, 1.0))

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
	turn_display.text = "🎮 Jugador %d\nTirada #%d" % [player_index + 1, turn_count]
	turn_display.add_theme_color_override("font_color", color.lightened(0.3))

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
	timer_display.text = "⏱ " + "%02d:%05.2f" % [minutes, seconds]

func show_feedback(text: String, color: Color) -> void:
	feedback_label.text = text
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate = Color(1, 1, 1, 0)

	var tween: Tween = create_tween()
	tween.tween_property(feedback_label, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_interval(2.5)
	tween.tween_property(feedback_label, "modulate", Color(1, 1, 1, 0), 0.5)

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
		dice_button.add_theme_font_size_override("font_size", 22)
	)
	tween.tween_interval(0.15)
	tween.tween_callback(func():
		dice_button.add_theme_font_size_override("font_size", 20)
	)
