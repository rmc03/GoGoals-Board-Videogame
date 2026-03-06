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
var ods_visuals: Dictionary = {}

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
		
		_apply_tile_visual(board_nodes[i], tile)
		tiles.append(tile)
	
	board_loaded.emit(tiles.size())

# --- CARGAR DESDE CONFIGURACIÓN ---

func load_config(
	ladders_config: Dictionary,
	slides_config: Dictionary,
	quiz_config: Dictionary,
	ods_visuals_config: Dictionary = {}
) -> void:
	ladders = ladders_config
	slides = slides_config
	quiz_tiles = quiz_config
	ods_visuals = ods_visuals_config

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
	if steps <= 0 or tiles.is_empty():
		return path

	var finish_index: int = tiles.size() - 1
	var current_pos: int = from_pos
	var direction: int = 1

	for _step in range(steps):
		if current_pos >= finish_index:
			direction = -1
		elif current_pos <= 0 and direction < 0:
			direction = 1

		current_pos += direction
		path.append(current_pos)

	return path

func _apply_tile_visual(board_node: Node2D, tile: TileEntity) -> void:
	if board_node == null or not board_node.has_method("configure_visual"):
		return

	var visual_kind: String = "normal"
	match tile.tile_type:
		TileEntity.TileType.START:
			visual_kind = "start"
		TileEntity.TileType.FINISH:
			visual_kind = "finish"
		TileEntity.TileType.QUIZ:
			visual_kind = "quiz"
		TileEntity.TileType.LADDER:
			visual_kind = "ladder"
		TileEntity.TileType.SLIDE:
			visual_kind = "slide"

	var visual_data: Dictionary = {
		"kind": visual_kind,
		"tile_index": tile.tile_index,
		"ods_id": tile.ods_id,
		"target_position": tile.target_position,
		"ods_meta": ods_visuals.get(tile.ods_id, {}).duplicate(true)
	}
	board_node.configure_visual(visual_data)

