extends RefCounted
class_name UIHelpers

# ============================================
# UTILIDADES UI COMPARTIDAS
# Funciones estáticas reutilizables para evitar
# duplicación entre PauseMenu y OptionsMenu
# ============================================

# --- Audio Volume Helpers ---

static func db_to_percent(value_db: float, min_db: float, max_db: float) -> float:
	if is_equal_approx(min_db, max_db):
		return 0.0
	return clampf(((value_db - min_db) / (max_db - min_db)) * 100.0, 0.0, 100.0)

static func percent_to_db(value_percent: float, min_db: float, max_db: float) -> float:
	return lerpf(min_db, max_db, clampf(value_percent, 0.0, 100.0) / 100.0)

# --- Display Mode Helpers ---

static func get_current_display_mode_index(window: Window) -> int:
	if window == null:
		return 1
	var current_mode: int = window.mode
	if current_mode == Window.MODE_FULLSCREEN or current_mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		return 0
	if window.borderless:
		return 2
	return 1

static func apply_window_mode(window: Window, target_mode: int, borderless: bool, maximize: bool) -> void:
	if window == null:
		return

	window.borderless = borderless
	window.mode = target_mode
	if target_mode == Window.MODE_FULLSCREEN and window.mode != Window.MODE_FULLSCREEN:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN

	if maximize:
		window.mode = Window.MODE_MAXIMIZED

	var window_id: int = window.get_window_id()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, borderless, window_id)
	DisplayServer.window_set_mode(_to_displayserver_mode(target_mode), window_id)
	if maximize:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED, window_id)

static func _to_displayserver_mode(window_mode: int) -> int:
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

static func resolve_display_mode_selection(index: int) -> Dictionary:
	## Returns {target_mode, borderless, maximize} for the given OptionButton index
	match index:
		0:
			return {"target_mode": Window.MODE_FULLSCREEN, "borderless": false, "maximize": false}
		1:
			return {"target_mode": Window.MODE_WINDOWED, "borderless": false, "maximize": false}
		2:
			return {"target_mode": Window.MODE_WINDOWED, "borderless": true, "maximize": true}
		_:
			return {"target_mode": Window.MODE_WINDOWED, "borderless": false, "maximize": false}

# --- StyleBox Factories ---

static func make_panel_style(
	bg: Color,
	border: Color,
	radius: int = 16,
	border_width: int = 1,
	shadow_size: int = 0,
	shadow_color: Color = Color(0, 0, 0, 0)
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_color = border
	style.shadow_size = shadow_size
	style.shadow_color = shadow_color
	return style

static func make_button_styles(
	base_color: Color,
	radius: int = 12,
	bottom_border: int = 3
) -> Dictionary:
	## Returns {"normal": StyleBoxFlat, "hover": StyleBoxFlat, "pressed": StyleBoxFlat}
	var normal := StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.corner_radius_top_left = radius
	normal.corner_radius_top_right = radius
	normal.corner_radius_bottom_left = radius
	normal.corner_radius_bottom_right = radius
	normal.border_width_bottom = bottom_border
	normal.border_color = base_color.darkened(0.35)

	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = base_color.lightened(0.12)

	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = base_color.darkened(0.12)
	pressed.border_width_bottom = 1

	return {"normal": normal, "hover": hover, "pressed": pressed}

static func apply_button_styles(button: Button, base_color: Color, radius: int = 12, font_size: int = 18, font_color: Color = Color.WHITE) -> void:
	var styles: Dictionary = make_button_styles(base_color, radius)
	button.add_theme_stylebox_override("normal", styles["normal"])
	button.add_theme_stylebox_override("hover", styles["hover"])
	button.add_theme_stylebox_override("pressed", styles["pressed"])
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
