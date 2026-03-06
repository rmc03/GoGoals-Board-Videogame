extends Node
class_name PlayersConfig

# ============================================
# CONFIGURACIÓN DE JUGADORES
# Proporciona las texturas y configuración de jugadores
# ============================================

# --- TEXTURAS DE JUGADORES ---
@export var player_textures: Array[Texture2D] = []

# --- CONFIGURACIÓN DE PARTIDA ---
var min_players: int = 1
var max_players: int = 4
var default_player_count: int = 1

# --- SEÑALES ---
signal config_loaded(texture_count: int)

func _ready() -> void:
	_setup_default_textures()

func _setup_default_textures() -> void:
	# Cargar texturas por defecto si no hay configuradas
	if player_textures.is_empty():
		# Intentar cargar texturas por defecto
		# Esto es un placeholder - las texturas reales vendrán del editor
		pass

# --- GETTERS ---

func get_min_players() -> int:
	return min_players

func get_max_players() -> int:
	return max_players

func get_default_player_count() -> int:
	return default_player_count

func get_player_texture(index: int) -> Texture2D:
	if index >= 0 and index < player_textures.size():
		return player_textures[index]
	return null

func get_all_textures() -> Array[Texture2D]:
	return player_textures

func get_texture_count() -> int:
	return player_textures.size()

# --- CONFIGURACIÓN ---

func set_player_count(count: int) -> void:
	count = clamp(count, min_players, max_players)
	default_player_count = count

func add_player_texture(texture: Texture2D) -> void:
	player_textures.append(texture)

func clear_textures() -> void:
	player_textures.clear()

# --- VALIDACIÓN ---

func is_valid_player_count(count: int) -> bool:
	return count >= min_players and count <= max_players

func is_valid_texture_index(index: int) -> bool:
	return index >= 0 and index < player_textures.size()
