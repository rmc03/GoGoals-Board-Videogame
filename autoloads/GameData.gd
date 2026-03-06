extends Node
class_name GameDataGlobal

var players_count: int = 1
var questions_db: Dictionary = {}
var question_history: Dictionary = {}

func _ready() -> void:
	randomize()
	load_questions()

func load_questions() -> void:
	var file_path: String = "res://data/questions.json"
	if FileAccess.file_exists(file_path):
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content: String = file.get_as_text()
			var json: JSON = JSON.new()
			var error: Error = json.parse(content)
			if error == OK:
				# The data is parsed as a Dictionary mapping String keys to Array of Dictionaries
				questions_db = json.data
			else:
				push_error("JSON Parse Error: ", json.get_error_message())
		else:
			push_error("Could not open questions file at ", file_path)
	else:
		push_error("Questions file not found at ", file_path)

func reset_question_history() -> void:
	question_history.clear()

func get_question(ods_number: int) -> Dictionary:
	var key: String = str(ods_number)
	if questions_db.has(key):
		var questions_for_ods: Array = questions_db[key]
		if questions_for_ods.size() > 0:
			var available_indexes: Array[int] = _get_available_question_indexes(key, questions_for_ods.size())
			var random_index: int = available_indexes[randi() % available_indexes.size()]
			_mark_question_as_used(key, random_index)
			return _prepare_question_data(questions_for_ods[random_index], ods_number, random_index)
	return {}

func _get_available_question_indexes(key: String, total_questions: int) -> Array[int]:
	var used_indexes: Array = question_history.get(key, [])
	var available_indexes: Array[int] = []

	for i in range(total_questions):
		if not used_indexes.has(i):
			available_indexes.append(i)

	if available_indexes.is_empty():
		question_history[key] = []
		for i in range(total_questions):
			available_indexes.append(i)

	return available_indexes

func _mark_question_as_used(key: String, question_index: int) -> void:
	var used_indexes: Array = question_history.get(key, [])
	used_indexes.append(question_index)
	question_history[key] = used_indexes

func _prepare_question_data(question_data: Dictionary, ods_number: int, question_index: int) -> Dictionary:
	var prepared_question: Dictionary = question_data.duplicate(true)
	var options: Array = prepared_question.get("options", []).duplicate()
	var correct_index: int = int(prepared_question.get("correct", -1))

	if correct_index >= 0 and correct_index < options.size():
		var option_entries: Array[Dictionary] = []
		for i in range(options.size()):
			option_entries.append({
				"text": str(options[i]),
				"is_correct": i == correct_index
			})

		option_entries.shuffle()

		var shuffled_options: Array[String] = []
		var shuffled_correct_index: int = -1
		for i in range(option_entries.size()):
			shuffled_options.append(option_entries[i]["text"])
			if option_entries[i]["is_correct"]:
				shuffled_correct_index = i

		prepared_question["options"] = shuffled_options
		prepared_question["correct"] = shuffled_correct_index
		prepared_question["correct_text"] = shuffled_options[shuffled_correct_index]
	else:
		prepared_question["correct_text"] = ""

	var explanation: String = str(prepared_question.get("explanation", "")).strip_edges()
	if explanation.is_empty():
		var correct_text: String = str(prepared_question.get("correct_text", "")).strip_edges()
		if not correct_text.is_empty():
			explanation = "La respuesta correcta es: %s." % correct_text

	prepared_question["explanation"] = explanation
	prepared_question["ods"] = ods_number
	prepared_question["question_index"] = question_index
	return prepared_question
