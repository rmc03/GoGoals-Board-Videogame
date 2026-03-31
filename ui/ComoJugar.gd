extends Control

const DISPLAY_FONT: FontFile = preload("res://Assets/Fonts/lilita-one/LilitaOne-Regular.ttf")
const SCREENSHOT_BOARD: Texture2D = preload("res://Assets/images/quiz/Screenshot 2025-12-10 201025.png")
const SCREENSHOT_QUIZ: Texture2D = preload("res://Assets/images/quiz/Screenshot 2025-12-10 201219.png")
const SCREENSHOT_RESULT: Texture2D = preload("res://Assets/images/quiz/Screenshot 2025-12-10 201254.png")
const SCREENSHOT_PAUSE: Texture2D = preload("res://Assets/images/quiz/Screenshot 2025-12-10 201338.png")

@onready var guide_panel: PanelContainer = $GuidePanel
@onready var title_label: Label = $GuidePanel/GuideMargin/GuideVBox/HeaderRow/HeaderText/TitleLabel
@onready var subtitle_label: Label = $GuidePanel/GuideMargin/GuideVBox/HeaderRow/HeaderText/SubtitleLabel
@onready var btn_volver: Button = $GuidePanel/GuideMargin/GuideVBox/HeaderRow/BotonVolver
@onready var guide_scroll: ScrollContainer = $GuidePanel/GuideMargin/GuideVBox/GuideScroll
@onready var content: VBoxContainer = $GuidePanel/GuideMargin/GuideVBox/GuideScroll/Content
var essentials_grid: GridContainer
var lower_sections_grid: GridContainer
var gallery_grid: GridContainer

func _ready() -> void:
	btn_volver.pressed.connect(_on_volver_pressed)
	guide_scroll.resized.connect(_sync_scroll_width)
	_style_shell()
	_build_content()
	call_deferred("_sync_scroll_width")
	call_deferred("_refresh_layout")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("_refresh_layout")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_on_volver_pressed()
		get_viewport().set_input_as_handled()

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/MenuPrincipal.tscn")

func _sync_scroll_width() -> void:
	if guide_scroll == null or content == null:
		return
	content.custom_minimum_size.x = max(guide_scroll.size.x - 12.0, 0.0)

func _refresh_layout() -> void:
	if guide_panel == null:
		return

	var viewport_size := get_viewport_rect().size
	var horizontal_margin := 56.0 if viewport_size.x >= 1080.0 else 28.0
	var vertical_margin := 36.0 if viewport_size.y >= 760.0 else 20.0
	var target_size := Vector2(
		clampf(viewport_size.x - horizontal_margin * 2.0, 760.0, 1120.0),
		clampf(viewport_size.y - vertical_margin * 2.0, 540.0, 680.0)
	)
	target_size.x = min(target_size.x, max(viewport_size.x - 24.0, 320.0))
	target_size.y = min(target_size.y, max(viewport_size.y - 24.0, 320.0))

	guide_panel.size = target_size
	guide_panel.position = (viewport_size - target_size) * 0.5

	if essentials_grid != null:
		essentials_grid.columns = 1 if target_size.x < 920.0 else 2

	if lower_sections_grid != null:
		lower_sections_grid.columns = 1 if target_size.x < 920.0 else 2

	if gallery_grid != null:
		gallery_grid.columns = 1 if target_size.x < 960.0 else 2

func _style_shell() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.1, 0.16, 0.95)
	panel_style.corner_radius_top_left = 24
	panel_style.corner_radius_top_right = 24
	panel_style.corner_radius_bottom_left = 24
	panel_style.corner_radius_bottom_right = 24
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.36, 0.62, 0.98, 0.4)
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel_style.shadow_size = 16
	guide_panel.add_theme_stylebox_override("panel", panel_style)

	title_label.add_theme_font_override("font", DISPLAY_FONT)
	title_label.add_theme_font_size_override("font_size", 34)
	title_label.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.08, 0.9))
	title_label.add_theme_constant_override("outline_size", 2)

	subtitle_label.add_theme_font_size_override("font_size", 17)
	subtitle_label.add_theme_color_override("font_color", Color(0.72, 0.81, 0.9))

	var close_normal := StyleBoxFlat.new()
	close_normal.bg_color = Color(1, 1, 1, 0.06)
	close_normal.corner_radius_top_left = 12
	close_normal.corner_radius_top_right = 12
	close_normal.corner_radius_bottom_left = 12
	close_normal.corner_radius_bottom_right = 12
	close_normal.border_width_left = 1
	close_normal.border_width_right = 1
	close_normal.border_width_top = 1
	close_normal.border_width_bottom = 1
	close_normal.border_color = Color(1, 1, 1, 0.16)

	var close_hover: StyleBoxFlat = close_normal.duplicate()
	close_hover.bg_color = Color(0.85, 0.22, 0.3, 0.24)
	close_hover.border_color = Color(0.97, 0.53, 0.57, 0.38)

	var close_pressed: StyleBoxFlat = close_normal.duplicate()
	close_pressed.bg_color = Color(0.78, 0.18, 0.25, 0.28)

	btn_volver.custom_minimum_size = Vector2(44, 44)
	btn_volver.focus_mode = Control.FOCUS_NONE
	btn_volver.add_theme_stylebox_override("normal", close_normal)
	btn_volver.add_theme_stylebox_override("hover", close_hover)
	btn_volver.add_theme_stylebox_override("pressed", close_pressed)
	btn_volver.add_theme_stylebox_override("focus", close_normal)

func _build_content() -> void:
	for child in content.get_children():
		child.queue_free()

	content.add_child(_make_hero_card())
	content.add_child(_make_section_title("Lo esencial"))

	essentials_grid = GridContainer.new()
	essentials_grid.columns = 2
	essentials_grid.add_theme_constant_override("h_separation", 14)
	essentials_grid.add_theme_constant_override("v_separation", 14)
	content.add_child(essentials_grid)

	essentials_grid.add_child(_make_info_card(
		"Objetivo",
		"Llega antes que los demás a la meta y aprovecha las casillas especiales para tomar ventaja.",
		Color(0.24, 0.66, 0.92)
	))
	essentials_grid.add_child(_make_info_card(
		"Tu turno",
		"Pulsa Tirar Dados, avanza tu ficha y observa si caes en una casilla normal, ODS, escalera o bajada.",
		Color(0.23, 0.69, 0.46)
	))
	essentials_grid.add_child(_make_info_card(
		"Casillas especiales",
		"Las escaleras te impulsan hacia arriba y las bajadas te hacen retroceder. Son clave para el ritmo de la partida.",
		Color(0.96, 0.69, 0.22)
	))
	essentials_grid.add_child(_make_info_card(
		"Preguntas ODS",
		"Si caes en una casilla temática, responderás una pregunta. Si aciertas, ganas ventaja; si fallas, termina tu turno.",
		Color(0.87, 0.36, 0.58)
	))

	content.add_child(_make_section_title("Cómo avanza una partida"))
	content.add_child(_make_steps_panel())

	lower_sections_grid = GridContainer.new()
	lower_sections_grid.columns = 2
	lower_sections_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lower_sections_grid.add_theme_constant_override("h_separation", 14)
	lower_sections_grid.add_theme_constant_override("v_separation", 14)
	content.add_child(lower_sections_grid)

	lower_sections_grid.add_child(_make_controls_panel())
	lower_sections_grid.add_child(_make_tips_panel())

	content.add_child(_make_section_title("Pantallas del juego"))
	content.add_child(_make_gallery_grid())

	var footer := Label.new()
	footer.text = "Consejo: si una pregunta te complica, fíjate en el color y el tema de la casilla para deducir mejor la respuesta."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 15)
	footer.add_theme_color_override("font_color", Color(0.64, 0.72, 0.82))
	content.add_child(footer)

func _make_hero_card() -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 112)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.14, 0.22, 0.96), Color(0.33, 0.58, 0.95, 0.55), 20))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	var intro := VBoxContainer.new()
	intro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro.add_theme_constant_override("separation", 6)
	row.add_child(intro)

	var title := Label.new()
	title.text = "Prepárate para la aventura"
	title.add_theme_font_override("font", DISPLAY_FONT)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	intro.add_child(title)

	var body := Label.new()
	body.text = "GoGoals mezcla tablero, azar y preguntas ODS. Tu meta es tomar buenas decisiones, responder bien y llegar a la casilla final antes que el resto."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", Color(0.8, 0.87, 0.94))
	intro.add_child(body)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(190, 0)
	badge.add_theme_stylebox_override("panel", _panel_style(Color(0.14, 0.24, 0.16, 0.96), Color(0.35, 0.78, 0.5, 0.52), 18))
	row.add_child(badge)

	var badge_margin := MarginContainer.new()
	badge_margin.add_theme_constant_override("margin_left", 14)
	badge_margin.add_theme_constant_override("margin_top", 14)
	badge_margin.add_theme_constant_override("margin_right", 14)
	badge_margin.add_theme_constant_override("margin_bottom", 14)
	badge.add_child(badge_margin)

	var badge_box := VBoxContainer.new()
	badge_box.add_theme_constant_override("separation", 4)
	badge_margin.add_child(badge_box)

	var badge_title := Label.new()
	badge_title.text = "Victoria"
	badge_title.add_theme_font_override("font", DISPLAY_FONT)
	badge_title.add_theme_font_size_override("font_size", 24)
	badge_title.add_theme_color_override("font_color", Color(0.93, 1.0, 0.94))
	badge_box.add_child(badge_title)

	var badge_text := Label.new()
	badge_text.text = "Gana quien alcance primero la meta y aproveche mejor los eventos del tablero."
	badge_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	badge_text.add_theme_font_size_override("font_size", 14)
	badge_text.add_theme_color_override("font_color", Color(0.79, 0.92, 0.82))
	badge_box.add_child(badge_text)

	return card

func _make_section_title(text: String) -> Control:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", DISPLAY_FONT)
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(0.97, 0.99, 1.0))
	return label

func _make_info_card(title: String, body: String, accent: Color) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 148)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.13, 0.2, 0.94), accent, 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var card_title := Label.new()
	card_title.text = title
	card_title.custom_minimum_size = Vector2(0, 32)
	card_title.add_theme_font_override("font", DISPLAY_FONT)
	card_title.add_theme_font_size_override("font_size", 22)
	card_title.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	box.add_child(card_title)

	var card_body := Label.new()
	card_body.text = body
	card_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_body.add_theme_font_size_override("font_size", 15)
	card_body.add_theme_color_override("font_color", Color(0.76, 0.84, 0.91))
	box.add_child(card_body)

	return card

func _make_steps_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.12, 0.19, 0.92), Color(0.28, 0.5, 0.85, 0.35), 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var steps_box := VBoxContainer.new()
	steps_box.add_theme_constant_override("separation", 12)
	margin.add_child(steps_box)

	var steps := [
		{"title": "1. Elige jugadores", "body": "Desde el menú principal selecciona cuántas personas participarán en la partida."},
		{"title": "2. Lanza y avanza", "body": "Cada jugador pulsa el botón del dado durante su turno y mueve su ficha automáticamente."},
		{"title": "3. Resuelve eventos", "body": "Al caer en una casilla especial, el juego puede hacerte subir, bajar o responder una pregunta."},
		{"title": "4. Mantén el ritmo", "body": "Si aciertas una pregunta ODS, obtienes una ventaja inmediata. Si fallas, el turno pasa al siguiente jugador."},
		{"title": "5. Llega a la meta", "body": "La partida termina cuando un jugador alcanza el final del recorrido y se muestra el resumen de victoria."}
	]

	for step in steps:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		steps_box.add_child(row)

		var number_chip := PanelContainer.new()
		number_chip.custom_minimum_size = Vector2(118, 0)
		number_chip.add_theme_stylebox_override("panel", _panel_style(Color(0.16, 0.23, 0.35, 0.95), Color(0.43, 0.63, 0.98, 0.45), 14))
		row.add_child(number_chip)

		var chip_label := Label.new()
		chip_label.text = step.title
		chip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		chip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		chip_label.add_theme_font_override("font", DISPLAY_FONT)
		chip_label.add_theme_font_size_override("font_size", 18)
		chip_label.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
		number_chip.add_child(chip_label)

		var body_label := Label.new()
		body_label.text = step.body
		body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body_label.add_theme_font_size_override("font_size", 15)
		body_label.add_theme_color_override("font_color", Color(0.78, 0.85, 0.92))
		row.add_child(body_label)

	return panel

func _make_controls_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.12, 0.19, 0.92), Color(0.32, 0.58, 0.94, 0.35), 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.text = "Controles rápidos"
	title.add_theme_font_override("font", DISPLAY_FONT)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	box.add_child(title)

	for item in [
		"Botón Tirar Dados: inicia tu turno",
		"Botón Pausa o tecla ESC: abre el menú de pausa",
		"En preguntas: haz clic sobre una opción para responder"
	]:
		var label := Label.new()
		label.text = item
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color(0.77, 0.84, 0.92))
		box.add_child(label)

	return panel

func _make_tips_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.1, 0.14, 0.18, 0.92), Color(0.95, 0.69, 0.25, 0.35), 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.text = "Consejos útiles"
	title.add_theme_font_override("font", DISPLAY_FONT)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color(1.0, 0.98, 0.93))
	box.add_child(title)

	for item in [
		"No cierres el quiz demasiado rápido: el panel marca la respuesta correcta en verde y las incorrectas en rojo.",
		"Observa el HUD para saber quién juega, cuántas tiradas van y cuándo conviene pausar.",
		"Las casillas especiales cambian mucho el ritmo: una buena escalera puede darte media partida."
	]:
		var label := Label.new()
		label.text = item
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color(0.86, 0.86, 0.81))
		box.add_child(label)

	return panel

func _make_gallery_grid() -> Control:
	gallery_grid = GridContainer.new()
	gallery_grid.columns = 2
	gallery_grid.add_theme_constant_override("h_separation", 14)
	gallery_grid.add_theme_constant_override("v_separation", 14)

	var gallery_items := [
		{"title": "Tablero principal", "caption": "Vista general del recorrido y las casillas especiales.", "texture": SCREENSHOT_BOARD},
		{"title": "Pregunta ODS", "caption": "Panel donde eliges la respuesta durante una casilla temática.", "texture": SCREENSHOT_QUIZ},
		{"title": "Resultado de respuesta", "caption": "La interfaz resalta aciertos y errores después de responder.", "texture": SCREENSHOT_RESULT},
		{"title": "Pausa y ajustes", "caption": "Aquí puedes retomar, reiniciar o volver al menú principal.", "texture": SCREENSHOT_PAUSE}
	]

	for item in gallery_items:
		gallery_grid.add_child(_make_gallery_card(item.title, item.caption, item.texture))

	return gallery_grid

func _make_gallery_card(title: String, caption: String, texture: Texture2D) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 272)
	card.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.12, 0.18, 0.94), Color(0.29, 0.46, 0.73, 0.35), 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var image := TextureRect.new()
	image.texture = texture
	image.custom_minimum_size = Vector2(0, 164)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(image)

	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_override("font", DISPLAY_FONT)
	title_label.add_theme_font_size_override("font_size", 21)
	title_label.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	box.add_child(title_label)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption_label.add_theme_font_size_override("font_size", 14)
	caption_label.add_theme_color_override("font_color", Color(0.74, 0.82, 0.9))
	box.add_child(caption_label)

	return card

func _panel_style(bg: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = border
	return style
