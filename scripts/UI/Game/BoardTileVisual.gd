@tool
extends StaticBody2D

const HEX_NEUTRAL_TEXTURE := preload("res://Assets/images/image-Picsart-BackgroundRemover (7).png")

const NEUTRAL_HEX_COLOR := Color(0.92, 0.90, 0.86, 1.0)
const LADDER_ACCENT := Color(0.23, 0.55, 0.28, 1.0)
const SLIDE_ACCENT := Color(0.11, 0.58, 0.70, 1.0)
const DARK_TEXT := Color(0.13, 0.11, 0.09, 1.0)
const LIGHT_TEXT := Color(1.0, 1.0, 1.0, 1.0)

@export_group("Texturas")
@export var ods_texture: Texture2D :
	set(value):
		ods_texture = value
		var s := _get_sprite()
		if s:
			if ods_texture != null:
				s.texture = ods_texture
				s.modulate = Color.WHITE
			else:
				_apply_best_fallback_texture()

@export var generic_texture: Texture2D :
	set(value):
		generic_texture = value
		var s := _get_sprite()
		if s and ods_texture == null:
			if generic_texture != null:
				s.texture = generic_texture
				s.modulate = Color.WHITE
			else:
				_apply_best_fallback_texture()

@export var normal_texture: Texture2D :
	set(value):
		normal_texture = value
		var s := _get_sprite()
		if s and ods_texture == null and generic_texture == null:
			if normal_texture != null:
				s.texture = normal_texture
				s.modulate = Color.WHITE
			else:
				_apply_best_fallback_texture()

@export var special_texture: Texture2D :
	set(value):
		special_texture = value
		var s := _get_sprite()
		if s and ods_texture == null and generic_texture == null and normal_texture == null:
			if special_texture != null:
				s.texture = special_texture
				s.modulate = Color.WHITE
			else:
				_apply_best_fallback_texture()

@export_group("Ajustes de Sprite")
@export var texture_scale: Vector2 = Vector2.ZERO :
	set(value):
		texture_scale = value
		var s := _get_sprite()
		if s:
			if texture_scale != Vector2.ZERO:
				s.scale = texture_scale
			queue_redraw()

@export var texture_offset: Vector2 = Vector2.ZERO :
	set(value):
		texture_offset = value
		var s := _get_sprite()
		if s:
			s.position = texture_offset
			queue_redraw()

func _get_sprite() -> Sprite2D:
	if not is_inside_tree():
		return null
	return get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	_apply_best_fallback_texture()
	var s := _get_sprite()
	if s:
		if texture_scale != Vector2.ZERO:
			s.scale = texture_scale
		if texture_offset != Vector2.ZERO:
			s.position = texture_offset

var visual_root: Node2D
var number_label: Label
var title_label: Label
var badge_label: Label

func configure_visual(data: Dictionary) -> void:
	_ensure_visual_nodes()
	_reset_visual_state()
	_apply_mirror_fix()

	var kind: String = str(data.get("kind", "normal"))
	match kind:
		"quiz":
			_configure_quiz(data)
		"start":
			_configure_start()
		"ladder":
			_configure_special("SUBE", LADDER_ACCENT)
		"slide":
			_configure_special("BAJA", SLIDE_ACCENT)
		"finish":
			visible = false
		_:
			_configure_normal()

func _ensure_visual_nodes() -> void:
	if visual_root == null:
		visual_root = Node2D.new()
		visual_root.name = "VisualRoot"
		visual_root.z_index = 10
		add_child(visual_root)

	if number_label == null:
		number_label = _create_label(
			"NumberLabel",
			Vector2(-44.0, -40.0),
			Vector2(30.0, 20.0),
			18,
			LIGHT_TEXT,
			4
		)
		number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if title_label == null:
		title_label = _create_label(
			"TitleLabel",
			Vector2(-45.0, -35.0),
			Vector2(90.0, 78.0),
			14,
			LIGHT_TEXT,
			3
		)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_label.clip_text = true
		title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	if badge_label == null:
		badge_label = _create_label(
			"BadgeLabel",
			Vector2(-54.0, -16.0),
			Vector2(108.0, 32.0),
			18,
			DARK_TEXT,
			3
		)
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _create_label(
	node_name: String,
	node_position: Vector2,
	node_size: Vector2,
	font_size: int,
	font_color: Color,
	outline_size: int
) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = node_position
	label.size = node_size
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = font_color
	settings.outline_size = outline_size
	settings.outline_color = Color(0.05, 0.05, 0.05, 0.95)
	settings.shadow_size = 2
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	settings.shadow_offset = Vector2(0.0, 2.0)
	label.label_settings = settings

	visual_root.add_child(label)
	return label

func _reset_visual_state() -> void:
	visible = true
	var s := _get_sprite()
	if s:
		s.visible = true
		s.texture = HEX_NEUTRAL_TEXTURE
		s.modulate = Color.WHITE

	number_label.visible = false
	number_label.text = ""

	title_label.visible = false
	title_label.text = ""
	title_label.modulate = Color.WHITE
	title_label.position = Vector2(-45.0, -35.0)
	title_label.size = Vector2(90.0, 78.0)

	badge_label.visible = false
	badge_label.text = ""

func _apply_mirror_fix() -> void:
	if visual_root == null:
		return

	visual_root.scale = Vector2(
		-1.0 if scale.x < 0.0 else 1.0,
		-1.0 if scale.y < 0.0 else 1.0
	)

func _apply_best_fallback_texture() -> void:
	var s := _get_sprite()
	if s == null:
		return
	if generic_texture != null:
		s.texture = generic_texture
		s.modulate = Color.WHITE
	elif normal_texture != null:
		s.texture = normal_texture
		s.modulate = Color.WHITE
	elif special_texture != null:
		s.texture = special_texture
		s.modulate = Color.WHITE
	else:
		s.texture = HEX_NEUTRAL_TEXTURE
		s.modulate = NEUTRAL_HEX_COLOR

func _configure_normal() -> void:
	var s := _get_sprite()
	if s == null:
		return
	if generic_texture != null:
		s.texture = generic_texture
		s.modulate = Color.WHITE
	elif normal_texture != null:
		s.texture = normal_texture
		s.modulate = Color.WHITE
	else:
		s.texture = HEX_NEUTRAL_TEXTURE
		s.modulate = NEUTRAL_HEX_COLOR

func _configure_start() -> void:
	_configure_normal()
	title_label.visible = true
	title_label.text = "INICIO"
	title_label.position = Vector2(-50.0, -16.0)
	title_label.size = Vector2(100.0, 36.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.pivot_offset = title_label.size / 2.0
	title_label.rotation = PI
	title_label.uppercase = true

	var settings := LabelSettings.new()
	settings.font_size = 22
	settings.font_color = Color(1.0, 1.0, 1.0, 1.0)       # Blanco puro
	settings.outline_size = 6
	settings.outline_color = Color(0.25, 0.18, 0.10, 1.0)  # Marrón oscuro
	settings.shadow_size = 4
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	settings.shadow_offset = Vector2(1.0, 3.0)
	title_label.label_settings = settings

func _configure_special(text: String, accent: Color) -> void:
	var s := _get_sprite()
	if s:
		if special_texture != null:
			s.texture = special_texture
			s.modulate = Color.WHITE
		elif generic_texture != null:
			s.texture = generic_texture
			s.modulate = Color.WHITE
		else:
			s.texture = HEX_NEUTRAL_TEXTURE
			s.modulate = NEUTRAL_HEX_COLOR
	badge_label.visible = false

func _configure_quiz(data: Dictionary) -> void:
	var ods_meta: Dictionary = data.get("ods_meta", {})
	var color_code: String = str(ods_meta.get("color", "#56C02B"))
	var tile_color := Color.from_string(color_code, Color(0.34, 0.75, 0.17, 1.0))

	var s := _get_sprite()
	if s:
		if ods_texture != null:
			s.texture = ods_texture
			s.modulate = Color.WHITE
		else:
			s.texture = HEX_NEUTRAL_TEXTURE
			s.modulate = tile_color

	# Los textos ODS se omiten — ahora se usan iconos visuales
	number_label.visible = false
	title_label.visible = false

func _set_label_style(label: Label, font_size: int, font_color: Color, outline_size: int) -> void:
	var settings: LabelSettings = label.label_settings
	if settings == null:
		settings = LabelSettings.new()
		label.label_settings = settings

	settings.font_size = font_size
	settings.font_color = font_color
	settings.outline_size = outline_size
	settings.outline_color = Color(0.05, 0.05, 0.05, 0.95)
	settings.shadow_size = 2
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	settings.shadow_offset = Vector2(0.0, 2.0)
