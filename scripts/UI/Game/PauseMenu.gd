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
	panel.size = Vector2(430, 350)
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
	subtitle_label.text = "Ajusta audio o continua la partida."
	subtitle_label.position = Vector2(30, 60)
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	panel.add_child(subtitle_label)

	_add_slider_row("Musica", 118, true)
	_add_slider_row("Efectos", 184, false)

	resume_button = _build_button("Continuar", Vector2(30, 262), Vector2(170, 44), Color(0.16, 0.45, 0.84))
	restart_button = _build_button("Reiniciar", Vector2(230, 262), Vector2(170, 44), Color(0.18, 0.32, 0.58))
	menu_button = _build_button("Menu principal", Vector2(30, 314), Vector2(370, 44), Color(0.32, 0.18, 0.24))

	resume_button.pressed.connect(func(): resume_requested.emit())
	restart_button.pressed.connect(func(): restart_requested.emit())
	menu_button.pressed.connect(func(): menu_requested.emit())

	root.resized.connect(_reposition_panel)
	_reposition_panel()
	_sync_slider_values()

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

func show_menu() -> void:
	if root == null:
		return

	_sync_slider_values()
	root.show()
	if resume_button:
		resume_button.grab_focus()

func hide_menu() -> void:
	if root:
		root.hide()

func is_open() -> bool:
	return root != null and root.visible
