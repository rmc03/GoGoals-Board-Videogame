extends Node2D

# --- CONFIGURACIÓN ---
@export var board_tiles: Array[Node2D] 
@export var player_textures: Array[Texture2D] 

@export_group("Sonidos y Música")
@export var music_background : AudioStream # Música de fondo
@export var sfx_dice_roll : AudioStream    # Sonido al tirar dado
@export var sfx_step : AudioStream         # Sonido de pisada (movimiento)
@export var sfx_ladder : AudioStream       # Sonido positivo (escalera)
@export var sfx_slide : AudioStream        # Sonido negativo (tobogán/río)
@export var sfx_correct : AudioStream      # Respuesta correcta
@export var sfx_wrong : AudioStream        # Respuesta incorrecta
@export var sfx_win : AudioStream          # Victoria final

var player_scene = preload("res://FichaJugador.tscn")

var special_movements = {
	8: 24,
	18: 13,
	28: 1,
	40: 26,
	43: 49,
	59: 35
}

var quiz_tiles = {
	2: 1, 6: 2, 11: 3, 14: 4, 17: 5, 19: 6, 23: 7, 27: 8, 
	31: 9, 34: 10, 37: 11, 41: 12, 44: 13, 47: 14, 52: 15, 
	55: 16, 61: 17
}

# --- VARIABLES MULTIJUGADOR ---
var players_nodes = []     
var players_positions = [] 
var players_turns = [] ### NUEVO: Array para contar turnos de cada jugador
var active_player_idx = 0  

var is_moving = false
var game_time = 0.0

# --- REFERENCIAS UI ---
@onready var dice_btn = $CanvasLayer/BotonDado
@onready var result_lbl = $CanvasLayer/LabelResultado
@onready var quiz_panel = $CanvasLayer/PanelQuiz
@onready var quiz_lbl = $CanvasLayer/PanelQuiz/LabelPregunta
@onready var timer_lbl = $CanvasLayer/LabelCronometro
@onready var turn_lbl = $CanvasLayer/LabelTurnos

func _ready():
	randomize()
	dice_btn.pressed.connect(roll_dice)
	setup_quiz_buttons()
	quiz_panel.hide()
	
		# NUEVO: Iniciar música de fondo
	if music_background:
		AudioManager.play_music(music_background)
	
	setup_game()

func setup_game():
	var count = GameData.players_count
	
	for i in range(count):
		var p = player_scene.instantiate()
		add_child(p)
		
		# Configurar Textura
		if i < player_textures.size() and player_textures[i] != null:
			p.get_node("Sprite").texture = player_textures[i]
		
		p.scale = Vector2(0.8, 0.8) 
		var offset = Vector2(i * 10, i * 5) 
		p.position = board_tiles[0].position + offset
		
		players_nodes.append(p)
		players_positions.append(0)
		players_turns.append(0) ### NUEVO: Inicializamos sus turnos en 0
	
	active_player_idx = 0
	update_ui_turn()

func _process(delta):
	if is_instance_valid(dice_btn) and not dice_btn.disabled:
		game_time += delta
		update_timer_display()

func update_ui_turn():
	# ### CORREGIDO: Mostramos también cuántos turnos lleva ese jugador
	turn_lbl.text = "Turno: Jugador " + str(active_player_idx + 1) + " (Tirada #" + str(players_turns[active_player_idx]) + ")"

func update_timer_display():
	var minutes = floor(game_time / 60)
	var seconds = fmod(game_time, 60)
	timer_lbl.text = "Tiempo: " + "%02d:%05.2f" % [minutes, seconds]

# --- LÓGICA DE JUEGO ---

func roll_dice():
	if is_moving: return
	
	# NUEVO: Sonido de dado ---
	AudioManager.play_sfx(sfx_dice_roll)
	
	# ### NUEVO: Aumentamos el contador de turnos del jugador actual
	players_turns[active_player_idx] += 1
	update_ui_turn() # Actualizamos el texto para ver el cambio
	
	dice_btn.disabled = true
	var roll = randi_range(1, 6)
	result_lbl.text = "J" + str(active_player_idx + 1) + " sacó: " + str(roll)
	
	move_active_player(roll)

func move_active_player(steps):
	is_moving = true
	var current_pos = players_positions[active_player_idx]
	var target_index = current_pos + steps
	
	if target_index >= board_tiles.size():
		var excess = target_index - (board_tiles.size() - 1)
		target_index = (board_tiles.size() - 1) - excess
	
	var player_node = players_nodes[active_player_idx]
	var tween = create_tween()
	
	var path = []
	if target_index > current_pos:
		for i in range(current_pos + 1, target_index + 1):
			path.append(i)
	else:
		for i in range(current_pos - 1, target_index - 1, -1):
			path.append(i)

	for idx in path:
		var offset = Vector2(active_player_idx * 10, active_player_idx * 5)
		tween.tween_property(player_node, "position", board_tiles[idx].position + offset, 0.3)
		# --- NUEVO: Sonido de paso en cada casilla ---
		# Usamos tween_callback para que suene sincronizado con el movimiento
		tween.tween_callback(func(): AudioManager.play_sfx(sfx_step, -5.0)) # -5.0 para que no sea muy fuert
		
	tween.tween_callback(func(): _on_movement_finished(target_index))

func _on_movement_finished(new_index):
	players_positions[active_player_idx] = new_index
	var player_node = players_nodes[active_player_idx]
	
	if new_index in special_movements:
		print("¡Especial!")
		var jump_to = special_movements[new_index]
		var offset = Vector2(active_player_idx * 10, active_player_idx * 5)
		
		if jump_to > new_index:
			AudioManager.play_sfx(sfx_ladder) # Subida
		else:
			AudioManager.play_sfx(sfx_slide)  # Bajada
		
		var tween = create_tween()
		tween.tween_property(player_node, "position", board_tiles[jump_to].position + offset, 0.5)
		await tween.finished
		
		players_positions[active_player_idx] = jump_to
		new_index = jump_to 
	
	if new_index in quiz_tiles:
		var ods_id = quiz_tiles[new_index]
		show_quiz(ods_id)
		
	elif new_index == board_tiles.size() - 1:
		handle_victory()
		
	else:
		end_turn()

func end_turn():
	active_player_idx += 1
	if active_player_idx >= players_nodes.size():
		active_player_idx = 0 
	
	is_moving = false
	dice_btn.disabled = false
	update_ui_turn()

# --- QUIZ ---

func show_quiz(ods_id):
	var data = GameData.get_question(ods_id)
	if data == null:
		end_turn()
		return
		
	quiz_lbl.text = "Pregunta para J" + str(active_player_idx + 1) + ":\n" + data["q"]
	
	var options = data["options"]
	var correct_idx = data["correct"]
	var buttons = [$CanvasLayer/PanelQuiz/BtnOp1, $CanvasLayer/PanelQuiz/BtnOp2, $CanvasLayer/PanelQuiz/BtnOp3]
	
	for i in range(buttons.size()):
		buttons[i].text = options[i]
		if buttons[i].pressed.is_connected(_on_answer_selected):
			buttons[i].pressed.disconnect(_on_answer_selected)
		buttons[i].pressed.connect(_on_answer_selected.bind(i == correct_idx))
	
	quiz_panel.show()

func _on_answer_selected(is_correct):
	quiz_panel.hide()
	
	if is_correct:
		AudioManager.play_sfx(sfx_correct) # NUEVO
		result_lbl.text = "¡Correcto! J" + str(active_player_idx + 1) + " tira otra vez."
		is_moving = false
		dice_btn.disabled = false
	else:
		AudioManager.play_sfx(sfx_wrong)   # NUEVO
		result_lbl.text = "Incorrecto."
		end_turn()

func handle_victory():
	AudioManager.play_sfx(sfx_win) # --- NUEVO
	AudioManager.stop_music()       # Opcional: Parar música de fondo para celebrar
	result_lbl.text = "¡JUGADOR " + str(active_player_idx + 1) + " GANA!"
	is_moving = false
	dice_btn.disabled = true
	
	var end_game_menu = preload("res://EndGameMenu.tscn").instantiate()
	
	# ### CORREGIDO: Pasamos los datos correctamente
	end_game_menu.final_time = game_time
	# Obtenemos los turnos SOLO del jugador que ganó (el active_player_idx actual)
	end_game_menu.final_turns = players_turns[active_player_idx]
	
	add_child(end_game_menu)
	set_process(false)

func setup_quiz_buttons():
	pass
