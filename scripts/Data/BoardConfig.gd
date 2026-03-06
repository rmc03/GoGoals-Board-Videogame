extends Node
class_name BoardConfig

var ladders: Dictionary = {
	8: 24,
	43: 49
}

var slides: Dictionary = {
	18: 13,
	28: 1,
	40: 26,
	59: 35
}

var quiz_tiles: Dictionary = {
	2: 1, 6: 2, 11: 3, 14: 4, 17: 5, 19: 6, 23: 7, 27: 8,
	31: 9, 34: 10, 37: 11, 41: 12, 44: 13, 47: 14, 52: 15,
	55: 16, 61: 17
}

func get_ladders() -> Dictionary:
	return ladders

func get_slides() -> Dictionary:
	return slides

func get_quiz_tiles() -> Dictionary:
	return quiz_tiles

func get_special_movements() -> Dictionary:
	var combined: Dictionary = ladders.duplicate()
	for key in slides:
		combined[key] = slides[key]
	return combined

func is_ladder_tile(tile_index: int) -> bool:
	return ladders.has(tile_index)

func is_slide_tile(tile_index: int) -> bool:
	return slides.has(tile_index)

func is_quiz_tile(tile_index: int) -> bool:
	return quiz_tiles.has(tile_index)

func get_target_position(tile_index: int) -> int:
	if ladders.has(tile_index):
		return ladders[tile_index]
	if slides.has(tile_index):
		return slides[tile_index]
	return -1

func get_ods_for_tile(tile_index: int) -> int:
	return quiz_tiles.get(tile_index, -1)
