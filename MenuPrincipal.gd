extends Control

# Referencias a tus botones principales
@onready var btn_jugar = $ButtonJugar
@onready var btn_ranking = $ButtonRanking # Asegúrate de que se llama así en tu escena
@onready var btn_salir = $ButtonSalir

# Referencias al nuevo panel (asegúrate de crearlos en la escena)
@onready var panel_seleccion = $PanelSeleccion
@onready var btn_1p = $PanelSeleccion/Btn1P
@onready var btn_2p = $PanelSeleccion/Btn2P
@onready var btn_3p = $PanelSeleccion/Btn3P
@onready var btn_4p = $PanelSeleccion/Btn4P
@onready var btn_cancelar_sel = $PanelSeleccion/BtnCancelar
@onready var btn_como_jugar = $ButtonComoJugar

# Referencias a la mini ventana de ranking
@onready var ventana_ranking = $VentanaRanking
@onready var ranking_lbl = $VentanaRanking/LabelRanking
@onready var btn_cerrar_ranking = $VentanaRanking/BotonCerrar

func _ready():
	# --- CONEXIONES DEL MENÚ PRINCIPAL ---
	btn_jugar.pressed.connect(_on_jugar_pressed)
	btn_ranking.pressed.connect(_on_ranking_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_como_jugar.pressed.connect(_on_como_jugar_pressed)
	
	# --- CONEXIONES DEL PANEL DE SELECCIÓN ---
	# Usamos .bind(N) para pasar el número de jugadores a la misma función
	btn_1p.pressed.connect(_on_players_selected.bind(1))
	btn_2p.pressed.connect(_on_players_selected.bind(2))
	btn_3p.pressed.connect(_on_players_selected.bind(3))
	btn_4p.pressed.connect(_on_players_selected.bind(4))
	
	# Usamos una función anónima (lambda) para la acción simple de cancelar
	btn_cancelar_sel.pressed.connect(func(): panel_seleccion.visible = false)
	
	# --- CONEXIÓN DE LA VENTANA DE RANKING ---
	btn_cerrar_ranking.pressed.connect(_on_cerrar_ranking_pressed)
	
	# Asegurarnos de que las ventanas empiecen ocultas
	ventana_ranking.visible = false
	panel_seleccion.visible = false

# --- FUNCIONES DE MANEJO DE EVENTOS ---

# Muestra el panel de selección de jugadores
func _on_jugar_pressed():
	panel_seleccion.visible = true

# Función común para todos los botones de selección
# ¡FUNCIÓN MOVIDA A NIVEL DE CLASE!
func _on_players_selected(cantidad):
	GameData.players_count = cantidad
	get_tree().change_scene_to_file("res://pantalla_de_juego.tscn")

# Muestra el ranking
func _on_ranking_pressed():
	# 1. Actualizamos los datos del ranking
	display_leaderboard()
	# 2. Mostramos la ventana
	ventana_ranking.visible = true
	
# Cierra la ventana de ranking
func _on_cerrar_ranking_pressed():
	ventana_ranking.visible = false
 
func _on_como_jugar_pressed():
	get_tree().change_scene_to_file("res://ComoJugar.tscn")

# Sale de la aplicación
func _on_salir_pressed():
	get_tree().quit()

# --- FUNCIONES DE SOPORTE ---

# Carga los datos y los formatea para el Label de la ventana de ranking
func display_leaderboard():
	# Asume que RecordsManager existe y tiene get_leaderboard()
	var leaderboard = RecordsManager.get_leaderboard() 
	var text = "[center][b]🏆 MEJORES JUGADORES 🏆[/b][/center]\n\n"
	
	if leaderboard.is_empty():
		text += "[center]¡Aún no hay registros![/center]"
	else:
		# Cabecera
		text += "Pos | Turnos | Tiempo | Nombre\n"
		text += "--------------------------------------------------------\n"
		
		for i in range(leaderboard.size()):
			var record = leaderboard[i]
			var minutes = floor(record.time / 60)
			var seconds = fmod(record.time, 60)
			# Formato de tiempo MM:SS.ms
			var time_str = "%02d:%05.2f" % [minutes, seconds]
			
			# Formato de línea
			# Ajusté los espacios para mejor legibilidad con BBCode
			text += "%3d | %6d | %7s | %s\n" % [i + 1, record.turns, time_str, record.name]

	ranking_lbl.text = text
	
	
