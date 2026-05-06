@tool
extends Node2D
class_name PlayerEntity

var player_index: int = 0
var current_position: int = 0
var turns_count: int = 0
var texture: Texture2D

var sprite: Sprite2D

@export var scale_factor: Vector2 = Vector2(3.2, 3.2) :
	set(value):
		scale_factor = value
		scale = scale_factor

@export var sprite_scale: Vector2 = Vector2.ZERO :
	set(value):
		sprite_scale = value
		if sprite and sprite_scale != Vector2.ZERO:
			sprite.scale = sprite_scale

@export var offset: Vector2 = Vector2.ZERO

signal position_changed(new_position: int)
signal texture_changed(new_texture: Texture2D)

func _ready() -> void:
	z_as_relative = false
	z_index = 20
	if not has_node("Sprite"):
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		add_child(sprite)
	else:
		sprite = get_node("Sprite")

	# Sombra sutil debajo del personaje
	if not Engine.is_editor_hint():
		_create_shadow()

	scale = scale_factor

	if sprite_scale != Vector2.ZERO:
		sprite.scale = sprite_scale

	if texture != null:
		sprite.texture = texture

func _create_shadow() -> void:
	var shadow := Sprite2D.new()
	shadow.name = "Shadow"
	shadow.z_index = -1
	shadow.position = Vector2(0, 14)
	shadow.scale = Vector2(0.8, 0.35)
	shadow.modulate = Color(0, 0, 0, 0.5)

	# Crear textura circular para la sombra
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center := Vector2(32, 32)
	var radius := 30.0
	for x in range(64):
		for y in range(64):
			var dist := Vector2(x, y).distance_to(center)
			var alpha := clampf(1.0 - (dist / radius), 0.0, 1.0)
			alpha = alpha * alpha  # Suavizar bordes
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
	var tex := ImageTexture.create_from_image(img)
	shadow.texture = tex
	add_child(shadow)
	move_child(shadow, 0)

func set_player_index(index: int) -> void:
	player_index = index

func set_texture(new_texture: Texture2D) -> void:
	texture = new_texture
	if sprite == null:
		sprite = get_node_or_null("Sprite")

	if sprite:
		sprite.texture = new_texture
		texture_changed.emit(new_texture)

func set_position_index(pos: int) -> void:
	current_position = pos
	position_changed.emit(pos)

func add_turn() -> void:
	turns_count += 1

func get_player_name() -> String:
	return "Jugador %d" % [player_index + 1]

func get_display_name() -> String:
	return "J%d" % [player_index + 1]

func setup(start_position: Vector2, player_texture: Texture2D = null) -> void:
	# Pequeño offset por jugador para que no se superpongan exactamente
	offset = Vector2(player_index * 4, player_index * 3) + Vector2(0, -22)
	position = start_position + offset

	if player_texture != null:
		set_texture(player_texture)

func calculate_display_position(board_position: Vector2) -> Vector2:
	return board_position + offset

func move_to(board_position: Vector2, duration: float = 0.3) -> Tween:
	var tween: Tween = create_tween()
	var target_pos: Vector2 = calculate_display_position(board_position)
	tween.tween_property(self, "position", target_pos, duration)
	return tween
