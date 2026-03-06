extends Node2D
class_name PlayerEntity

var player_index: int = 0
var current_position: int = 0
var turns_count: int = 0
var texture: Texture2D

var sprite: Sprite2D

@export var scale_factor: Vector2 = Vector2(0.8, 0.8)
@export var offset: Vector2 = Vector2.ZERO

signal position_changed(new_position: int)
signal texture_changed(new_texture: Texture2D)

func _ready() -> void:
	if not has_node("Sprite"):
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		add_child(sprite)
	else:
		sprite = get_node("Sprite")

	sprite.scale = scale_factor

	if texture != null:
		sprite.texture = texture

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
	offset = Vector2(player_index * 10, player_index * 5)
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
