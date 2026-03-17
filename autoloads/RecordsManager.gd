extends Node

var records: Array = []

const MAX_RECORDS: int = 10 
const RECORDS_FILE: String = "user://records.save"

func _ready() -> void:
	load_records()

func load_records() -> void:
	if not FileAccess.file_exists(RECORDS_FILE):
		return 

	var file: FileAccess = FileAccess.open(RECORDS_FILE, FileAccess.READ)
	if FileAccess.get_open_error() == OK:
		var text: String = file.get_as_text()
		var content = JSON.parse_string(text)
		if content is Array:
			records = content
		file.close()

func save_records() -> void:
	var file: FileAccess = FileAccess.open(RECORDS_FILE, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(JSON.stringify(records))
		file.close()

func submit_new_record(player_name: String, time: float, turns: int) -> bool:
	var new_record: Dictionary = {"name": player_name, "time": time, "turns": turns}
	
	for i in range(records.size()):
		var record: Dictionary = records[i]
		if record.name.to_lower() == player_name.to_lower():
			if turns < record.turns or (turns == record.turns and time < record.time):
				records.remove_at(i)
				records.append(new_record)
				_organize_and_save()
				return true
			else:
				return false 
	
	records.append(new_record)
	_organize_and_save()
	return true

func _organize_and_save() -> void:
	records.sort_custom(_sort_records)
	
	if records.size() > MAX_RECORDS:
		records.resize(MAX_RECORDS)
		
	save_records()

func _sort_records(a: Dictionary, b: Dictionary) -> bool:
	if a.turns != b.turns:
		return a.turns < b.turns 
	else:
		return a.time < b.time

func get_leaderboard() -> Array:
	return records

func reset_records() -> void:
	records.clear()
	save_records()
