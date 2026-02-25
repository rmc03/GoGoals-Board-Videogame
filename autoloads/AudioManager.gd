extends Node

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(music_player)
	music_player.volume_db = -10.0

func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	
	if music_player.stream == stream and music_player.playing:
		return
		
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream, volume_mod: float = 0.0) -> void:
	if stream == null:
		return
	
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = stream
	sfx_player.volume_db = volume_mod
	
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()

func stop_music() -> void:
	music_player.stop()
