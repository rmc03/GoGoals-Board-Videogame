extends StaticBody2D

const HEX_NEUTRAL_TEXTURE := preload("res://Assets/images/image-Picsart-BackgroundRemover (7).png")

const NEUTRAL_HEX_COLOR := Color(0.92, 0.90, 0.86, 1.0)
const LADDER_ACCENT := Color(0.23, 0.55, 0.28, 1.0)
const SLIDE_ACCENT := Color(0.11, 0.58, 0.70, 1.0)
const DARK_TEXT := Color(0.13, 0.11, 0.09, 1.0)
const LIGHT_TEXT := Color(1.0, 1.0, 1.0, 1.0)

@onready var sprite: Sprite2D = $Sprite2D

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
			Vector2(-50.0, -16.0),
			Vector2(100.0, 86.0),
			14,
			LIGHT_TEXT,
			3
		)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

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
	label.clip_text = false
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING

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
	sprite.visible = true
	sprite.texture = HEX_NEUTRAL_TEXTURE
	sprite.modulate = Color.WHITE

	number_label.visible = false
	number_label.text = ""

	title_label.visible = false
	title_label.text = ""
	title_label.modulate = Color.WHITE
	title_label.position = Vector2(-50.0, -16.0)
	title_label.size = Vector2(100.0, 86.0)

	badge_label.visible = false
	badge_label.text = ""

func _apply_mirror_fix() -> void:
	if visual_root == null:
		return

	visual_root.scale = Vector2(
		-1.0 if scale.x < 0.0 else 1.0,
		-1.0 if scale.y < 0.0 else 1.0
	)

func _configure_normal() -> void:
	sprite.texture = HEX_NEUTRAL_TEXTURE
	sprite.modulate = NEUTRAL_HEX_COLOR

func _configure_start() -> void:
	_configure_normal()
	title_label.visible = true
	title_label.text = "INICIO"
	title_label.position = Vector2(-50.0, -18.0)
	title_label.size = Vector2(100.0, 40.0)
	_set_label_style(title_label, 16, DARK_TEXT, 3)

func _configure_special(text: String, accent: Color) -> void:
	_configure_normal()
	badge_label.visible = true
	badge_label.text = text
	_set_label_style(badge_label, 22, accent, 4)

func _configure_quiz(data: Dictionary) -> void:
	var ods_id: int = int(data.get("ods_id", 0))
	var ods_meta: Dictionary = data.get("ods_meta", {})
	var title: String = str(ods_meta.get("title", "ODS"))
	var font_size: int = int(ods_meta.get("font_size", 17))
	var color_code: String = str(ods_meta.get("color", "#56C02B"))
	var tile_color := Color.from_string(color_code, Color(0.34, 0.75, 0.17, 1.0))

	sprite.texture = HEX_NEUTRAL_TEXTURE
	sprite.modulate = tile_color

	number_label.visible = true
	number_label.text = str(ods_id)
	_set_label_style(number_label, 18, LIGHT_TEXT, 4)

	title_label.visible = true
	title_label.text = title
	_set_label_style(title_label, font_size, LIGHT_TEXT, 4)

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
