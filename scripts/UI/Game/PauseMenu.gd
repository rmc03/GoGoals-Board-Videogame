extends Node
class_name PauseMenuUI

signal resume_requested()
signal restart_requested()
signal menu_requested()

var host: CanvasLayer
var root: Control
var overlay: ColorRect
var panel: Panel
var music_slider: HSlider
var sfx_slider: HSlider
var music_value_label: Label
var sfx_value_label: Label
var resume_button: Button
var restart_button: Button
var menu_button: Button
var display_mode_option: OptionButton
var use_keyboard_navigation: bool = false
var interactive_controls: Array[Control] = []

func setup(target_host: CanvasLayer) -> void:
	host = target_host
	_build_menu()
	hide_menu()

func _build_menu() -> void:
	root = Control.new()
	root.name = "PauseMenuRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	host.add_child(root)

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.02, 0.05, 0.62)
	root.add_child(overlay)

	panel = Panel.new()
	panel.size = Vector2(430, 410)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.1, 0.16, 0.96)
	panel_style.corner_radius_top_left = 22
	panel_style.corner_radius_top_right = 22
	panel_style.corner_radius_bottom_left = 22
	panel_style.corner_radius_bottom_right = 22
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.35, 0.6, 1.0, 0.55)
	panel_style.shadow_size = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", panel_style)

	var title_label: Label = Label.new()
	title_label.text = "Juego en pausa"
	title_label.position = Vector2(30, 24)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	panel.add_child(title_label)

	var subtitle_label: Label = Label.new()
	subtitle_label.text = "Ajusta el audio o continúa la partida."
	subtitle_label.position = Vector2(30, 60)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	panel.add_child(subtitle_label)

	_add_slider_row("Música", 118, true)
	_add_slider_row("Efectos", 184, false)

	_add_display_mode_row(250)

	resume_button = _build_button("Continuar", Vector2(30, 310), Vector2(170, 44), Color(0.16, 0.45, 0.84))
	restart_button = _build_button("Reiniciar", Vector2(230, 310), Vector2(170, 44), Color(0.18, 0.32, 0.58))
	menu_button = _build_button("Menú principal", Vector2(30, 362), Vector2(370, 44), Color(0.32, 0.18, 0.24))

	resume_button.pressed.connect(func(): resume_requested.emit())
	restart_button.pressed.connect(func(): restart_requested.emit())
	menu_button.pressed.connect(func(): menu_requested.emit())

	root.resized.connect(_reposition_panel)
	_reposition_panel()
	_sync_slider_values()
	_register_interactive_controls()
	_apply_navigation_mode()

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
	slider.size = Vector2(290, 24)
	panel.add_child(slider)

	var value_label: Label = Label.new()
	value_label.position = Vector2(334, y + 18)
	value_label.size = Vector2(70, 30)
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
	display_mode_option.position = Vector2(110, y - 4)
	display_mode_option.size = Vector2(290, 32)
	
	display_mode_option.add_item("Pantalla completa", 0)
	display_mode_option.add_item("Ventana", 1)
	display_mode_option.add_item("Sin bordes", 2)
	
	_sync_display_mode()
	display_mode_option.item_selected.connect(_on_display_mode_selected)
	panel.add_child(display_mode_option)

func _sync_display_mode() -> void:
	if display_mode_option == null:
		return
	var window: Window = get_window()
	if window == null:
		window = get_tree().get_root()
	display_mode_option.selected = UIHelpers.get_current_display_mode_index(window)

func _on_display_mode_selected(index: int) -> void:
	var config: Dictionary = UIHelpers.resolve_display_mode_selection(index)
	call_deferred("_apply_window_mode", config["target_mode"], config["borderless"], config["maximize"])

func _apply_window_mode(target_mode: int, borderless: bool, maximize: bool) -> void:
	var window: Window = get_window()
	if window == null:
		window = get_tree().get_root()
	UIHelpers.apply_window_mode(window, target_mode, borderless, maximize)

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

	var focus: StyleBoxFlat = normal.duplicate()
	focus.border_width_left = 2
	focus.border_width_right = 2
	focus.border_width_top = 2
	focus.border_width_bottom = 2
	focus.border_color = Color(1.0, 1.0, 1.0, 0.9)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(button)
	return button

func _register_interactive_controls() -> void:
	interactive_controls = [
		music_slider,
		sfx_slider,
		display_mode_option,
		resume_button,
		restart_button,
		menu_button
	]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_set_keyboard_navigation(false)
	elif event is InputEventMouseButton and event.pressed:
		_set_keyboard_navigation(false)
	elif event is InputEventKey and event.pressed and not event.echo:
		_set_keyboard_navigation(true)
	elif event is InputEventJoypadButton and event.pressed:
		_set_keyboard_navigation(true)

func _set_keyboard_navigation(enabled: bool) -> void:
	if use_keyboard_navigation == enabled:
		return

	use_keyboard_navigation = enabled
	_apply_navigation_mode()

	if not root or not root.visible:
		return

	if use_keyboard_navigation:
		if not _menu_has_focus() and resume_button:
			resume_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func _apply_navigation_mode() -> void:
	var focus_mode := Control.FOCUS_ALL if use_keyboard_navigation else Control.FOCUS_NONE
	for control in interactive_controls:
		if control:
			control.focus_mode = focus_mode

func _menu_has_focus() -> bool:
	var focus_owner := get_viewport().gui_get_focus_owner()
	return focus_owner != null and root != null and root.is_ancestor_of(focus_owner)

func _reposition_panel() -> void:
	if panel == null:
		return

	var viewport_size: Vector2 = root.get_viewport_rect().size
	panel.position = (viewport_size - panel.size) / 2.0

func _sync_slider_values() -> void:
	if music_slider:
		music_slider.value = UIHelpers.db_to_percent(AudioManager.get_music_volume(), Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX)
		_update_value_label(music_value_label, music_slider.value)

	if sfx_slider:
		sfx_slider.value = UIHelpers.db_to_percent(AudioManager.get_sfx_volume(), Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX)
		_update_value_label(sfx_value_label, sfx_slider.value)

func _update_value_label(label: Label, value_percent: float) -> void:
	if label:
		label.text = "%d%%" % int(round(value_percent))

func _on_music_slider_changed(value: float) -> void:
	_update_value_label(music_value_label, value)
	AudioManager.set_music_volume(UIHelpers.percent_to_db(value, Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX))

func _on_sfx_slider_changed(value: float) -> void:
	_update_value_label(sfx_value_label, value)
	AudioManager.set_sfx_volume(UIHelpers.percent_to_db(value, Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX))

func show_menu() -> void:
	if root == null:
		return

	_sync_slider_values()
	_sync_display_mode()
	root.show()
	_apply_navigation_mode()
	if use_keyboard_navigation and resume_button:
		resume_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func hide_menu() -> void:
	if root:
		get_viewport().gui_release_focus()
		root.hide()

func is_open() -> bool:
	return root != null and root.visible
