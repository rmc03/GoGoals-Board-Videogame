extends Node2D
class_name BoardEntity

# ============================================
# ENTIDAD TABLERO
# Gestiona el tablero completo y sus casillas
# ============================================

# --- PROPIEDADES ---
var tiles: Array[TileEntity] = []
var board_tiles_nodes: Array[Node2D] = []  # Referencias a nodos del escenario

# --- CONFIGURACIÓN DEL TABLERO ---
var total_tiles: int = 63  # Tablero tradicional de 0-62
var ladders: Dictionary = {}    # {casilla_origen: casillas_destino}
var slides: Dictionary = {}     # {casilla_origen: casillas_destino}
var quiz_tiles: Dictionary = {}  # {casilla: id_ods}

# --- SEÑALES ---
signal board_loaded(tile_count: int)

func _ready() -> void:
	pass

# --- CONFIGURACIÓN ---

func setup(board_nodes: Array[Node2D]) -> void:
	board_tiles_nodes = board_nodes
	total_tiles = board_nodes.size()
	
	# Crear entidades de casillas
	tiles.clear()
	for i in range(board_nodes.size()):
		var tile = TileEntity.new()
		tile.name = "Tile_%d" % i
		add_child(tile)
		
		# Configurar según tipo
		if i == 0:
			tile.setup(i, TileEntity.TileType.START)
		elif i == board_nodes.size() - 1:
			tile.setup(i, TileEntity.TileType.FINISH)
		elif ladders.has(i):
			tile.setup_as_ladder(i, ladders[i])
		elif slides.has(i):
			tile.setup_as_slide(i, slides[i])
		elif quiz_tiles.has(i):
			tile.setup_as_quiz(i, quiz_tiles[i])
		else:
			tile.setup(i, TileEntity.TileType.NORMAL)
		
		tiles.append(tile)
	
	board_loaded.emit(tiles.size())

# --- CARGAR DESDE CONFIGURACIÓN ---

func load_config(ladders_config: Dictionary, slides_config: Dictionary, quiz_config: Dictionary) -> void:
	ladders = ladders_config
	slides = slides_config
	quiz_tiles = quiz_config

# --- CONSULTAS ---

func get_tile_position(tile_index: int) -> Vector2:
	if tile_index >= 0 and tile_index < board_tiles_nodes.size():
		return board_tiles_nodes[tile_index].position
	return Vector2.ZERO

func get_tile(tile_index: int) -> TileEntity:
	if tile_index >= 0 and tile_index < tiles.size():
		return tiles[tile_index]
	return null

func get_tile_count() -> int:
	return tiles.size()

func get_finish_index() -> int:
	return tiles.size() - 1

# --- GESTIÓN DE CASILLAS ESPECIALES ---

func has_ladder_at(tile_index: int) -> bool:
	return ladders.has(tile_index)

func has_slide_at(tile_index: int) -> bool:
	return slides.has(tile_index)

func has_quiz_at(tile_index: int) -> bool:
	return quiz_tiles.has(tile_index)

func get_ladder_target(tile_index: int) -> int:
	return ladders.get(tile_index, -1)

func get_slide_target(tile_index: int) -> int:
	return slides.get(tile_index, -1)

func get_quiz_id(tile_index: int) -> int:
	return quiz_tiles.get(tile_index, -1)

# --- CÁLCULO DE RUTA ---

func calculate_path(from_pos: int, steps: int) -> Array[int]:
	var path: Array[int] = []
	var target = from_pos + steps
	
	# Ajustar si se pasa del final
	if target >= tiles.size():
		var excess = target - (tiles.size() - 1)
		target = (tiles.size() - 1) - excess
	
	# Generar camino
	if target > from_pos:
		for i in range(from_pos + 1, target + 1):
			path.append(i)
	else:
		for i in range(from_pos - 1, target - 1, -1):
			path.append(i)
	
	return path

