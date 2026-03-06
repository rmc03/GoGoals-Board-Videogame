extends Node

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var music_volume_db: float = Constants.MUSIC_VOLUME_DEFAULT
var sfx_volume_db: float = Constants.SFX_VOLUME_DEFAULT

func _ready() -> void:
	add_child(music_player)
	_load_settings()
	music_player.volume_db = music_volume_db

func _exit_tree() -> void:
	stop_music()
	music_player.stream = null

func _is_headless() -> bool:
	return DisplayServer.get_name() == "headless"

func _load_settings() -> void:
	music_volume_db = Constants.MUSIC_VOLUME_DEFAULT
	sfx_volume_db = Constants.SFX_VOLUME_DEFAULT

	if not FileAccess.file_exists(Constants.SETTINGS_FILE):
		return

	var file: FileAccess = FileAccess.open(Constants.SETTINGS_FILE, FileAccess.READ)
	if file == null or FileAccess.get_open_error() != OK:
		return

	var content: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if content is Dictionary:
		music_volume_db = clampf(float(content.get("music_volume_db", music_volume_db)), Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX)
		sfx_volume_db = clampf(float(content.get("sfx_volume_db", sfx_volume_db)), Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX)

func _save_settings() -> void:
	var file: FileAccess = FileAccess.open(Constants.SETTINGS_FILE, FileAccess.WRITE)
	if file == null or FileAccess.get_open_error() != OK:
		return

	var content: Dictionary = {
		"music_volume_db": music_volume_db,
		"sfx_volume_db": sfx_volume_db
	}
	file.store_string(JSON.stringify(content))
	file.close()

func set_music_volume(volume_db: float, persist: bool = true) -> void:
	music_volume_db = clampf(volume_db, Constants.MUSIC_VOLUME_MIN, Constants.MUSIC_VOLUME_MAX)
	music_player.volume_db = music_volume_db
	if persist:
		_save_settings()

func set_sfx_volume(volume_db: float, persist: bool = true) -> void:
	sfx_volume_db = clampf(volume_db, Constants.SFX_VOLUME_MIN, Constants.SFX_VOLUME_MAX)
	if persist:
		_save_settings()

func get_music_volume() -> float:
	return music_volume_db

func get_sfx_volume() -> float:
	return sfx_volume_db

func reset_settings() -> void:
	set_music_volume(Constants.MUSIC_VOLUME_DEFAULT, false)
	set_sfx_volume(Constants.SFX_VOLUME_DEFAULT, false)
	_save_settings()

func play_music(stream: AudioStream) -> void:
	if stream == null or _is_headless():
		return
	
	if music_player.stream == stream and music_player.playing:
		return
		
	music_player.stream = stream
	music_player.volume_db = music_volume_db
	music_player.play()

func play_sfx(stream: AudioStream, volume_mod: float = 0.0) -> void:
	if stream == null or _is_headless():
		return
	
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = stream
	sfx_player.volume_db = sfx_volume_db + volume_mod
	
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()

func stop_music() -> void:
	music_player.stop()
