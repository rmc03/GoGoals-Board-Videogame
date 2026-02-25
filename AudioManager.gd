extends Node

# Este nodo se encargará de reproducir la música de fondo
var music_player = AudioStreamPlayer.new()

func _ready():
	# Configuramos el reproductor de música
	add_child(music_player)
	music_player.volume_db = -10.0 # Bajar un poco el volumen por defecto

# Función para reproducir música
func play_music(stream: AudioStream):
	if stream == null: return
	
	if music_player.stream == stream and music_player.playing:
		return # Ya está sonando esta canción, no hacemos nada
		
	music_player.stream = stream
	music_player.play()

# Función para reproducir efectos de sonido (SFX)
# Crea un reproductor temporal para que se puedan superponer sonidos
func play_sfx(stream: AudioStream, volume_mod: float = 0.0):
	if stream == null: return
	
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = stream
	sfx_player.volume_db = volume_mod
	
	# Conectamos la señal para borrar el nodo cuando termine el sonido
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()

# Función para detener la música
func stop_music():
	music_player.stop()
