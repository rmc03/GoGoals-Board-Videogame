# RecordsManager.gd
extends Node

# Estructura del récord: {name: String, time: float, turns: int}
var records = []

# --- AQUÍ ESTÁ EL LÍMITE ---
# Si quieres que salgan más de 10 personas, cambia este número.
const MAX_RECORDS = 10 
const RECORDS_FILE = "user://records.save"

func _ready():
	load_records()

func load_records():
	if not FileAccess.file_exists(RECORDS_FILE):
		return # No hay archivo aún

	var file = FileAccess.open(RECORDS_FILE, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var text = file.get_as_text()
		var content = JSON.parse_string(text)
		if content is Array:
			records = content
		file.close()

func save_records():
	var file = FileAccess.open(RECORDS_FILE, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(records))
		file.close()

# Cambiamos "name" por "player_name" en los argumentos para evitar el error
func submit_new_record(player_name: String, time: float, turns: int):
	print("--- INTENTANDO GUARDAR RÉCORD ---")
	print("Nombre: ", player_name, " | Turnos: ", turns, " | Tiempo: ", time)
	
	# Aquí usamos player_name como valor
	var new_record = {"name": player_name, "time": time, "turns": turns}
	
	# 1. Comprobar si el jugador ya existe
	for i in range(records.size()):
		var record = records[i]
		# Comparamos record.name (del diccionario) con nuestra variable player_name
		if record.name.to_lower() == player_name.to_lower():
			print("El usuario ya existe en el ranking.")
			
			if turns < record.turns or (turns == record.turns and time < record.time):
				print("¡Nueva mejor puntuación! Actualizando...")
				records.remove_at(i)
				records.append(new_record)
				_organize_and_save()
				return true
			else:
				print("La puntuación nueva es peor o igual. NO SE GUARDA.")
				return false 
	
	# 2. Si es un jugador nuevo
	print("Usuario nuevo. Añadiendo al ranking.")
	records.append(new_record)
	_organize_and_save()
	return true

func _organize_and_save():
	# Ordenar: Menos turnos es mejor. Si empate, menos tiempo.
	records.sort_custom(_sort_records)
	
	# Cortar si hay demasiados (Aquí se aplica el límite)
	if records.size() > MAX_RECORDS:
		print("Límite superado, eliminando al último del ranking.")
		records.resize(MAX_RECORDS)
		
	save_records()

func _sort_records(a, b):
	if a.turns != b.turns:
		return a.turns < b.turns 
	else:
		return a.time < b.time

func get_leaderboard():
	return records
