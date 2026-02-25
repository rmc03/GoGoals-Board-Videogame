extends Node2D

# region CONFIGURACIÓN
@export var board_tiles: Array[Node2D] 
@export var player_textures: Array[Texture2D] 

@export_group("Sonidos y Música")
@export var music_background: AudioStream 
@export var sfx_dice_roll: AudioStream   
@export var sfx_step: AudioStream        
@export var sfx_ladder: AudioStream      
@export var sfx_slide: AudioStream       
@export var sfx_correct: AudioStream     
@export var sfx_wrong: AudioStream       
@export var sfx_win: AudioStream         

var player_scene: PackedScene = preload("res://scenes/FichaJugador.tscn")

var special_movements: Dictionary = {
	8: 24,
	18: 13,
	28: 1,
	40: 26,
	43: 49,
	59: 35
}

var quiz_tiles: Dictionary = {
	2: 1, 6: 2, 11: 3, 14: 4, 17: 5, 19: 6, 23: 7, 27: 8, 
	31: 9, 34: 10, 37: 11, 41: 12, 44: 13, 47: 14, 52: 15, 
	55: 16, 61: 17
}
# endregion

# region VARIABLES MULTIJUGADOR
var players_nodes: Array[Node] = []     
var players_positions: Array[int] = [] 
var players_turns: Array[int] = [] 
var active_player_idx: int = 0  

var is_moving: bool = false
var game_time: float = 0.0
# endregion

# region REFERENCIAS UI
@onready var dice_btn: Button = $CanvasLayer/BotonDado
@onready var result_lbl: Label = $CanvasLayer/LabelResultado
@onready var quiz_panel: Panel = $CanvasLayer/PanelQuiz
@onready var quiz_lbl: Label = $CanvasLayer/PanelQuiz/LabelPregunta
@onready var timer_lbl: Label = $CanvasLayer/LabelCronometro
@onready var turn_lbl: Label = $CanvasLayer/LabelTurnos
# endregion

func _ready() -> void:
	randomize()
	dice_btn.pressed.connect(roll_dice)
	setup_quiz_buttons()
	quiz_panel.hide()
	
	if music_background:
		AudioManager.play_music(music_background)
	
	setup_game()

func setup_game() -> void:
	var count: int = GameData.players_count
	
	for i in range(count):
		var p: Node2D = player_scene.instantiate()
		add_child(p)
		
		if i < player_textures.size() and player_textures[i] != null:
			p.get_node("Sprite").texture = player_textures[i]
		
		p.scale = Vector2(0.8, 0.8) 
		var offset: Vector2 = Vector2(i * 10, i * 5) 
		p.position = board_tiles[0].position + offset
		
		players_nodes.append(p)
		players_positions.append(0)
		players_turns.append(0) 
	
	active_player_idx = 0
	update_ui_turn()

func _process(delta: float) -> void:
	if is_instance_valid(dice_btn) and not dice_btn.disabled:
		game_time += delta
		update_timer_display()

func update_ui_turn() -> void:
	turn_lbl.text = "Turno: Jugador " + str(active_player_idx + 1) + " (Tirada #" + str(players_turns[active_player_idx]) + ")"

func update_timer_display() -> void:
	var minutes: int = floor(game_time / 60.0)
	var seconds: float = fmod(game_time, 60.0)
	timer_lbl.text = "Tiempo: " + "%02d:%05.2f" % [minutes, seconds]

# region LÓGICA DE JUEGO

func roll_dice() -> void:
	if is_moving: return
	
	AudioManager.play_sfx(sfx_dice_roll)
	
	players_turns[active_player_idx] += 1
	update_ui_turn() 
	
	dice_btn.disabled = true
	var roll: int = randi_range(1, 6)
	result_lbl.text = "J" + str(active_player_idx + 1) + " sacó: " + str(roll)
	
	move_active_player(roll)

func move_active_player(steps: int) -> void:
	is_moving = true
	var current_pos: int = players_positions[active_player_idx]
	var target_index: int = current_pos + steps
	
	if target_index >= board_tiles.size():
		var excess: int = target_index - (board_tiles.size() - 1)
		target_index = (board_tiles.size() - 1) - excess
	
	var player_node: Node2D = players_nodes[active_player_idx]
	var tween: Tween = create_tween()
	
	var path: Array[int] = []
	if target_index > current_pos:
		for i in range(current_pos + 1, target_index + 1):
			path.append(i)
	else:
		for i in range(current_pos - 1, target_index - 1, -1):
			path.append(i)

	for idx in path:
		var offset: Vector2 = Vector2(active_player_idx * 10, active_player_idx * 5)
		tween.tween_property(player_node, "position", board_tiles[idx].position + offset, 0.3)
		tween.tween_callback(func(): AudioManager.play_sfx(sfx_step, -5.0)) 
		
	tween.tween_callback(func(): _on_movement_finished(target_index))

func _on_movement_finished(new_index: int) -> void:
	players_positions[active_player_idx] = new_index
	var player_node: Node2D = players_nodes[active_player_idx]
	
	if new_index in special_movements:
		print("¡Especial!")
		var jump_to: int = special_movements[new_index]
		var offset: Vector2 = Vector2(active_player_idx * 10, active_player_idx * 5)
		
		if jump_to > new_index:
			AudioManager.play_sfx(sfx_ladder) 
		else:
			AudioManager.play_sfx(sfx_slide)  
		
		var tween: Tween = create_tween()
		tween.tween_property(player_node, "position", board_tiles[jump_to].position + offset, 0.5)
		await tween.finished
		
		players_positions[active_player_idx] = jump_to
		new_index = jump_to 
	
	if new_index in quiz_tiles:
		var ods_id: int = quiz_tiles[new_index]
		show_quiz(ods_id)
		
	elif new_index == board_tiles.size() - 1:
		handle_victory()
		
	else:
		end_turn()

func end_turn() -> void:
	active_player_idx += 1
	if active_player_idx >= players_nodes.size():
		active_player_idx = 0 
	
	is_moving = false
	dice_btn.disabled = false
	update_ui_turn()

# endregion

# region QUIZ

func show_quiz(ods_id: int) -> void:
	var data: Dictionary = GameData.get_question(ods_id)
	if data.is_empty():
		end_turn()
		return
		
	quiz_lbl.text = "Pregunta para J" + str(active_player_idx + 1) + ":\n" + data["q"]
	
	var options: Array = data["options"]
	var correct_idx: int = data["correct"]
	var buttons: Array = [$CanvasLayer/PanelQuiz/BtnOp1, $CanvasLayer/PanelQuiz/BtnOp2, $CanvasLayer/PanelQuiz/BtnOp3]
	
	for i in range(buttons.size()):
		if i < options.size():
			buttons[i].text = options[i]
			buttons[i].show()
			
			if buttons[i].pressed.is_connected(_on_answer_selected):
				buttons[i].pressed.disconnect(_on_answer_selected)
			buttons[i].pressed.connect(_on_answer_selected.bind(i == correct_idx))
		else:
			buttons[i].hide() # Ocultar botones sin opción
	
	quiz_panel.show()

func _on_answer_selected(is_correct: bool) -> void:
	quiz_panel.hide()
	
	if is_correct:
		AudioManager.play_sfx(sfx_correct) 
		result_lbl.text = "¡Correcto! J" + str(active_player_idx + 1) + " tira otra vez."
		is_moving = false
		dice_btn.disabled = false
	else:
		AudioManager.play_sfx(sfx_wrong)   
		result_lbl.text = "Incorrecto."
		end_turn()

func handle_victory() -> void:
	AudioManager.play_sfx(sfx_win) 
	AudioManager.stop_music()       
	result_lbl.text = "¡JUGADOR " + str(active_player_idx + 1) + " GANA!"
	is_moving = false
	dice_btn.disabled = true
	
	var end_game_menu: Node = preload("res://ui/EndGameMenu.tscn").instantiate()
	
	end_game_menu.final_time = game_time
	end_game_menu.final_turns = players_turns[active_player_idx]
	
	add_child(end_game_menu)
	set_process(false)

func setup_quiz_buttons() -> void:
	pass

# endregion
