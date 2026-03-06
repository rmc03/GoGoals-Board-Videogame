extends Node2D
class_name TileEntity

# ============================================
# ENTIDAD CASILLA (TILE)
# Representa una casilla del tablero
# ============================================

# --- TIPOS DE CASILLA ---
enum TileType {
	NORMAL,      # Casilla normal
	START,       # Casilla de inicio
	FINISH,      # Casilla final
	QUIZ,        # Casilla con pregunta ODS
	LADDER,      # Escalera - sube posiciones
	SLIDE        # Deslizador - baja posiciones
}

# --- PROPIEDADES ---
var tile_index: int = 0
var tile_type: TileType = TileType.NORMAL
var ods_id: int = 0  # ID de pregunta ODS si es QUIZ
var target_position: int = 0  # Para LADDER o SLIDE

# --- REFERENCIAS ---
@export var sprite: Sprite2D

func _ready() -> void:
	_setup_visual()

func _setup_visual() -> void:
	# Configurar apariencia según tipo
	match tile_type:
		TileType.QUIZ:
			# Mostrar ícono de pregunta
			pass
		TileType.LADDER:
			# Mostrar ícono de escalera
			pass
		TileType.SLIDE:
			# Mostrar ícono de deslizador
			pass
		TileType.FINISH:
			# Mostrar ícono de finish
			pass

# --- CONFIGURACIÓN ---

func setup(index: int, type: TileType = TileType.NORMAL, ods: int = 0, target: int = 0) -> void:
	tile_index = index
	tile_type = type
	ods_id = ods
	target_position = target

func setup_as_quiz(index: int, ods_number: int) -> void:
	tile_index = index
	tile_type = TileType.QUIZ
	ods_id = ods_number

func setup_as_ladder(index: int, target: int) -> void:
	tile_index = index
	tile_type = TileType.LADDER
	target_position = target

func setup_as_slide(index: int, target: int) -> void:
	tile_index = index
	tile_type = TileType.SLIDE
	target_position = target

# --- UTILIDADES ---

func is_special() -> bool:
	return tile_type == TileType.LADDER or tile_type == TileType.SLIDE

func is_quiz() -> bool:
	return tile_type == TileType.QUIZ

func is_finish() -> bool:
	return tile_type == TileType.FINISH

func get_description() -> String:
	match tile_type:
		TileType.NORMAL:
			return "Casilla normal"
		TileType.START:
			return "Inicio"
		TileType.FINISH:
			return "Meta"
		TileType.QUIZ:
			return "Pregunta ODS #%d" % ods_id
		TileType.LADDER:
			return "Escalera -> %d" % target_position
		TileType.SLIDE:
			return "Deslizador -> %d" % target_position
	return ""
