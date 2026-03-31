extends Node
class_name MenuOptionsUI

signal closed()

var host: Control
var root: Control
var overlay: ColorRect
var panel: Panel

var music_slider: HSlider
var sfx_slider: HSlider
var music_value_label: Label
var sfx_value_label: Label
var display_mode_option: OptionButton

var reset_audio_button: Button
var reset_records_button: Button
var close_button: Button

var reset_records_timer: Timer
var reset_records_state: int = 0

const RESET_RECORDS_TEXT := "Restablecer ranking"
const RESET_RECORDS_CONFIRM_TEXT := "Confirmar borrado"
const RESET_RECORDS_DONE_TEXT := "Ranking reiniciado"

func setup(target_host: Control) -> void:
	host = target_host
	_build_menu()
	hide_menu()

func _build_menu() -> void:
	root = Control.new()
	root.name = "MenuOptionsRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	host.add_child(root)

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.02, 0.05, 0.6)
	root.add_child(overlay)

	panel = Panel.new()
	panel.size = Vector2(500, 460)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.1, 0.16, 0.97)
	panel_style.corner_radius_top_left = 22
	panel_style.corner_radius_top_right = 22
	panel_style.corner_radius_bottom_left = 22
	panel_style.corner_radius_bottom_right = 22
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.35, 0.62, 1.0, 0.6)
	panel_style.shadow_size = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", panel_style)

	var title_label: Label = Label.new()
	title_label.text = "Opciones"
	title_label.position = Vector2(30, 22)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	panel.add_child(title_label)

	var subtitle_label: Label = Label.new()
	subtitle_label.text = "Ajusta el audio, la pantalla y los datos locales."
	subtitle_label.position = Vector2(30, 58)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	panel.add_child(subtitle_label)

	_add_slider_row("Música", 116, true)
	_add_slider_row("Efectos", 182, false)
	_add_display_mode_row(248)

	reset_audio_button = _build_button("Restablecer audio", Vector2(30, 318), Vector2(210, 40), Color(0.18, 0.32, 0.58))
	reset_records_button = _build_button(RESET_RECORDS_TEXT, Vector2(260, 318), Vector2(210, 40), Color(0.32, 0.18, 0.24))
	close_button = _build_button("Cerrar", Vector2(30, 370), Vector2(440, 44), Color(0.16, 0.45, 0.84))

	reset_audio_button.pressed.connect(_on_reset_audio_pressed)
	reset_records_button.pressed.connect(_on_reset_records_pressed)
	close_button.pressed.connect(_on_close_pressed)

	reset_records_timer = Timer.new()
	reset_records_timer.one_shot = true
	reset_records_timer.wait_time = 2.0
	reset_records_timer.timeout.connect(_on_reset_records_timeout)
	root.add_child(reset_records_timer)

	root.resized.connect(_reposition_panel)
	_reposition_panel()
	_sync_slider_values()
	_sync_display_mode()

func _add_slider_row(label_text: String, y: float, is_music: bool) -> void:
	var row_label: Label = Label.new()
	row_label.text = label_text
	row_label.position = Vector2(30, y)
	row_label.add_theme_font_size_override("font_size", 18)
	row_label.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	panel.add_child(row_label)

	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.position = Vector2(30, y + 28)
	slider.size = Vector2(310, 24)
	panel.add_child(slider)

	var value_label: Label = Label.new()
	value_label.position = Vector2(360, y + 18)
	value_label.size = Vector2(90, 30)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color(0.7, 0.86, 1.0))
	panel.add_child(value_label)

	if is_music:
		music_slider = slider
		music_value_label = value_label
		music_slider.value_changed.connect(_on_music_slider_changed)
	else:
		sfx_slider = slider
		sfx_value_label = value_label
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _add_display_mode_row(y: float) -> void:
	var row_label: Label = Label.new()
	row_label.text = "Pantalla"
	row_label.position = Vector2(30, y)
	row_label.add_theme_font_size_override("font_size", 18)
	row_label.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	panel.add_child(row_label)

	display_mode_option = OptionButton.new()
	display_mode_option.position = Vector2(120, y - 4)
	display_mode_option.size = Vector2(330, 32)
	display_mode_option.add_item("Pantalla completa", 0)
	display_mode_option.add_item("Ventana", 1)
	display_mode_option.add_item("Sin bordes", 2)
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	panel.add_child(display_mode_option)

func _build_button(text: String, position: Vector2, size: Vector2, color: Color) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.position = position
	button.size = size

	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_bottom = 3
	normal.border_color = color.darkened(0.35)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = color.lightened(0.12)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = color.darkened(0.12)
	pressed.border_width_bottom = 1

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(button)
	return button

func _reposition_panel() -> void:
	if panel == null:
		return
	var viewport_size: Vector2 = root.get_viewport_rect().size
	panel.position = (viewport_size - panel.size) / 2.0

func _db_to_percent(value_db: float, min_db: float, max_db: float) -> float:
	if is_equal_approx(min_db, max_db):
		return 0.0
	return clampf(((value_db - min_db) / (max_db - min_db)) * 100.0, 0.0, 100.0)

func _percent_to_db(value_percent: float, min_db: float, max_db: float) -> float:
	return lerpf(min_db, max_db, clampf(value_percent, 0.0, 100.0) / 100.0)

func _sync_slider_values() -> void:
	if music_slider:
		music_slider.value = _db_to_percent(AudioManager.get_music_volume(), Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX)
		_update_value_label(music_value_label, music_slider.value)

	if sfx_slider:
		sfx_slider.value = _db_to_percent(AudioManager.get_sfx_volume(), Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX)
		_update_value_label(sfx_value_label, sfx_slider.value)

func _update_value_label(label: Label, value_percent: float) -> void:
	if label:
		label.text = "%d%%" % int(round(value_percent))

func _on_music_slider_changed(value: float) -> void:
	_update_value_label(music_value_label, value)
	AudioManager.set_music_volume(_percent_to_db(value, Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX))

func _on_sfx_slider_changed(value: float) -> void:
	_update_value_label(sfx_value_label, value)
	AudioManager.set_sfx_volume(_percent_to_db(value, Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX))

func _sync_display_mode() -> void:
	if display_mode_option == null:
		return
	var window := _get_window()
	var current_mode: int = window.mode
	if current_mode == Window.MODE_FULLSCREEN or current_mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		display_mode_option.selected = 0
	else:
		display_mode_option.selected = 2 if window.borderless else 1

func _on_display_mode_selected(index: int) -> void:
	match index:
		0:
			_request_window_mode(Window.MODE_FULLSCREEN, false, false)
		1:
			_request_window_mode(Window.MODE_WINDOWED, false, false)
		2:
			_request_window_mode(Window.MODE_WINDOWED, true, true)

func _request_window_mode(target_mode: int, borderless: bool, maximize: bool) -> void:
	call_deferred("_apply_window_mode", target_mode, borderless, maximize)

func _apply_window_mode(target_mode: int, borderless: bool, maximize: bool) -> void:
	var window := _get_window()
	if window == null:
		return

	window.borderless = borderless
	window.mode = target_mode
	if target_mode == Window.MODE_FULLSCREEN and window.mode != Window.MODE_FULLSCREEN:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN

	if maximize:
		window.mode = Window.MODE_MAXIMIZED

	_apply_displayserver_fallback(window, target_mode, borderless, maximize)

func _apply_displayserver_fallback(window: Window, target_mode: int, borderless: bool, maximize: bool) -> void:
	var window_id: int = window.get_window_id()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless, window_id)
	DisplayServer.window_set_mode(_to_displayserver_mode(target_mode), window_id)
	if maximize:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED, window_id)

func _to_displayserver_mode(window_mode: int) -> int:
	match window_mode:
		Window.MODE_WINDOWED:
			return DisplayServer.WINDOW_MODE_WINDOWED
		Window.MODE_FULLSCREEN:
			return DisplayServer.WINDOW_MODE_FULLSCREEN
		Window.MODE_EXCLUSIVE_FULLSCREEN:
			return DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		Window.MODE_MAXIMIZED:
			return DisplayServer.WINDOW_MODE_MAXIMIZED
		_:
			return DisplayServer.WINDOW_MODE_WINDOWED

func _get_window() -> Window:
	var window := get_window()
	if window == null:
		window = get_tree().get_root()
	return window

func _on_reset_audio_pressed() -> void:
	AudioManager.reset_settings()
	_sync_slider_values()

func _on_reset_records_pressed() -> void:
	if reset_records_state == 0:
		reset_records_state = 1
		reset_records_button.text = RESET_RECORDS_CONFIRM_TEXT
		reset_records_timer.start()
		return

	if reset_records_state == 1:
		reset_records_state = 2
		reset_records_button.text = RESET_RECORDS_DONE_TEXT
		RecordsManager.reset_records()
		reset_records_timer.start()

func _on_reset_records_timeout() -> void:
	reset_records_state = 0
	reset_records_button.text = RESET_RECORDS_TEXT

func _on_close_pressed() -> void:
	hide_menu()
	closed.emit()

func show_menu() -> void:
	if root == null:
		return
	_reset_records_ui()
	_sync_slider_values()
	_sync_display_mode()
	root.show()
	if close_button:
		close_button.grab_focus()

func hide_menu() -> void:
	if root:
		root.hide()

func _reset_records_ui() -> void:
	reset_records_state = 0
	if reset_records_timer:
		reset_records_timer.stop()
	if reset_records_button:
		reset_records_button.text = RESET_RECORDS_TEXT

func is_open() -> bool:
	return root != null and root.visible
