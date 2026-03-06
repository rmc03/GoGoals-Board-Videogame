extends RefCounted
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

var ods_visuals: Dictionary = {
	1: {
		"title": "FIN DE LA\nPOBREZA",
		"color": "#E5243B",
		"font_size": 18
	},
	2: {
		"title": "HAMBRE\nCERO",
		"color": "#DDA63A",
		"font_size": 19
	},
	3: {
		"title": "SALUD Y\nBIENESTAR",
		"color": "#4C9F38",
		"font_size": 18
	},
	4: {
		"title": "EDUCACION\nDE CALIDAD",
		"color": "#C5192D",
		"font_size": 17
	},
	5: {
		"title": "IGUALDAD DE\nGENERO",
		"color": "#FF3A21",
		"font_size": 17
	},
	6: {
		"title": "AGUA LIMPIA Y\nSANEAMIENTO",
		"color": "#26BDE2",
		"font_size": 15
	},
	7: {
		"title": "ENERGIA\nASEQUIBLE Y NO\nCONTAMINANTE",
		"color": "#FCC30B",
		"font_size": 13
	},
	8: {
		"title": "TRABAJO\nDECENTE Y\nCRECIMIENTO\nECONOMICO",
		"color": "#A21942",
		"font_size": 12
	},
	9: {
		"title": "INDUSTRIA,\nINNOVACION E\nINFRAESTRUCTURA",
		"color": "#FD6925",
		"font_size": 12
	},
	10: {
		"title": "REDUCCION DE LAS\nDESIGUALDADES",
		"color": "#DD1367",
		"font_size": 13
	},
	11: {
		"title": "CIUDADES Y\nCOMUNIDADES\nSOSTENIBLES",
		"color": "#FD9D24",
		"font_size": 13
	},
	12: {
		"title": "PRODUCCION Y\nCONSUMO\nRESPONSABLES",
		"color": "#BF8B2E",
		"font_size": 12
	},
	13: {
		"title": "ACCION\nPOR EL CLIMA",
		"color": "#3F7E44",
		"font_size": 17
	},
	14: {
		"title": "VIDA\nSUBMARINA",
		"color": "#0A97D9",
		"font_size": 18
	},
	15: {
		"title": "VIDA DE\nECOSISTEMAS\nTERRESTRES",
		"color": "#56C02B",
		"font_size": 13
	},
	16: {
		"title": "PAZ, JUSTICIA E\nINSTITUCIONES\nSOLIDAS",
		"color": "#00689D",
		"font_size": 12
	},
	17: {
		"title": "ALIANZAS PARA\nLOGRAR LOS\nOBJETIVOS",
		"color": "#19486A",
		"font_size": 12
	}
}

func get_ladders() -> Dictionary:
	return ladders

func get_slides() -> Dictionary:
	return slides

func get_quiz_tiles() -> Dictionary:
	return quiz_tiles

func get_ods_visuals() -> Dictionary:
	return ods_visuals.duplicate(true)

func get_ods_visual(ods_id: int) -> Dictionary:
	return ods_visuals.get(ods_id, {}).duplicate(true)

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
