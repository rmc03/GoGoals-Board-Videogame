extends Node
class_name GameDataGlobal

var players_count: int = 1
var questions_db: Dictionary = {}

func _ready() -> void:
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

func get_question(ods_number: int) -> Dictionary:
    var key: String = str(ods_number)
    if questions_db.has(key):
        var questions_for_ods: Array = questions_db[key]
        if questions_for_ods.size() > 0:
            return questions_for_ods.pick_random()
    return {}
