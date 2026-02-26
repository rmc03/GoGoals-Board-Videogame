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

var PLAYER_COLORS: Array[Color] = [
	Color(0.6, 0.2, 0.8),   # Morado
	Color(0.9, 0.2, 0.2),   # Rojo
	Color(0.2, 0.7, 0.3),   # Verde
	Color(0.2, 0.5, 0.9),   # Azul
]
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

# HUD dinámico
var hud_panel: Panel
var dice_result_lbl: Label
var feedback_lbl: Label
# endregion

func _ready() -> void:
	randomize()
	_build_hud()
	_style_quiz_panel()
	dice_btn.pressed.connect(roll_dice)
	quiz_panel.hide()
	
	if music_background:
		AudioManager.play_music(music_background)
	
	setup_game()

# region ESTILIZACIÓN UI

func _build_hud() -> void:
	# --- Ocultar labels originales, usaremos los del HUD ---
	timer_lbl.visible = false
	result_lbl.visible = false
	turn_lbl.visible = false
	
	# --- Panel HUD con fondo semitransparente ---
	hud_panel = Panel.new()
	hud_panel.offset_left = 1065
	hud_panel.offset_top = 30
	hud_panel.offset_right = 1340
	hud_panel.offset_bottom = 280
	
	var hud_style: StyleBoxFlat = StyleBoxFlat.new()
	hud_style.bg_color = Color(0.05, 0.08, 0.15, 0.85)
	hud_style.corner_radius_top_left = 16
	hud_style.corner_radius_top_right = 16
	hud_style.corner_radius_bottom_left = 16
	hud_style.corner_radius_bottom_right = 16
	hud_style.border_width_left = 2
	hud_style.border_width_right = 2
	hud_style.border_width_top = 2
	hud_style.border_width_bottom = 2
	hud_style.border_color = Color(0.3, 0.6, 1.0, 0.6)
	hud_style.shadow_color = Color(0, 0, 0, 0.4)
	hud_style.shadow_size = 6
	hud_panel.add_theme_stylebox_override("panel", hud_style)
	$CanvasLayer.add_child(hud_panel)
	
	# --- Cronómetro ---
	var timer_new: Label = Label.new()
	timer_new.name = "HUDTimer"
	timer_new.text = "⏱ 00:00.00"
	timer_new.position = Vector2(15, 12)
	timer_new.add_theme_font_size_override("font_size", 18)
	timer_new.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	hud_panel.add_child(timer_new)
	
	# --- Botón de Dado estilizado ---
	dice_btn.reparent(hud_panel)
	dice_btn.position = Vector2(15, 45)
	dice_btn.size = Vector2(245, 55)
	
	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.15, 0.45, 0.85)
	btn_normal.corner_radius_top_left = 12
	btn_normal.corner_radius_top_right = 12
	btn_normal.corner_radius_bottom_left = 12
	btn_normal.corner_radius_bottom_right = 12
	btn_normal.border_width_bottom = 4
	btn_normal.border_color = Color(0.1, 0.3, 0.6)
	
	var btn_hover: StyleBoxFlat = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.2, 0.55, 0.95)
	
	var btn_pressed: StyleBoxFlat = btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.1, 0.35, 0.7)
	btn_pressed.border_width_bottom = 1
	
	var btn_disabled: StyleBoxFlat = btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.25, 0.25, 0.3)
	btn_disabled.border_color = Color(0.2, 0.2, 0.25)
	
	dice_btn.add_theme_stylebox_override("normal", btn_normal)
	dice_btn.add_theme_stylebox_override("hover", btn_hover)
	dice_btn.add_theme_stylebox_override("pressed", btn_pressed)
	dice_btn.add_theme_stylebox_override("disabled", btn_disabled)
	dice_btn.add_theme_font_size_override("font_size", 20)
	dice_btn.add_theme_color_override("font_color", Color.WHITE)
	dice_btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.8))
	dice_btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))
	
	# --- Resultado del dado (grande, centrado) ---
	dice_result_lbl = Label.new()
	dice_result_lbl.name = "DiceResult"
	dice_result_lbl.text = ""
	dice_result_lbl.position = Vector2(15, 110)
	dice_result_lbl.size = Vector2(245, 30)
	dice_result_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_result_lbl.add_theme_font_size_override("font_size", 20)
	dice_result_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	hud_panel.add_child(dice_result_lbl)
	
	# --- Feedback (correcto/incorrecto) ---
	feedback_lbl = Label.new()
	feedback_lbl.name = "Feedback"
	feedback_lbl.text = ""
	feedback_lbl.position = Vector2(15, 145)
	feedback_lbl.size = Vector2(245, 50)
	feedback_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_lbl.add_theme_font_size_override("font_size", 16)
	feedback_lbl.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	hud_panel.add_child(feedback_lbl)
	
	# --- Turno del jugador ---
	var turn_new: Label = Label.new()
	turn_new.name = "HUDTurn"
	turn_new.text = ""
	turn_new.position = Vector2(15, 205)
	turn_new.size = Vector2(245, 55)
	turn_new.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	turn_new.add_theme_font_size_override("font_size", 15)
	turn_new.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	hud_panel.add_child(turn_new)

func _style_quiz_panel() -> void:
	# --- Estilizar el panel del quiz ---
	var quiz_style: StyleBoxFlat = StyleBoxFlat.new()
	quiz_style.bg_color = Color(0.06, 0.1, 0.2, 0.96)
	quiz_style.corner_radius_top_left = 20
	quiz_style.corner_radius_top_right = 20
	quiz_style.corner_radius_bottom_left = 20
	quiz_style.corner_radius_bottom_right = 20
	quiz_style.border_width_left = 3
	quiz_style.border_width_right = 3
	quiz_style.border_width_top = 3
	quiz_style.border_width_bottom = 3
	quiz_style.border_color = Color(0.3, 0.7, 1.0, 0.7)
	quiz_style.shadow_color = Color(0, 0, 0, 0.7)
	quiz_style.shadow_size = 15
	quiz_panel.add_theme_stylebox_override("panel", quiz_style)
	
	# Estilizar la pregunta
	quiz_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	quiz_lbl.add_theme_font_size_override("font_size", 24)
	
	# Estilizar los botones de opciones
	var buttons: Array = [$CanvasLayer/PanelQuiz/BtnOp1, $CanvasLayer/PanelQuiz/BtnOp2, $CanvasLayer/PanelQuiz/BtnOp3]
	for btn in buttons:
		_style_quiz_button(btn)

func _style_quiz_button(btn: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.25, 0.45)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(0.3, 0.5, 0.8, 0.5)
	normal.content_margin_left = 15
	normal.content_margin_right = 15
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color(0.18, 0.4, 0.7)
	hover.border_color = Color(0.4, 0.7, 1.0, 0.9)
	
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color(0.08, 0.2, 0.4)
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 0.85))

# endregion

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
	var color: Color = PLAYER_COLORS[active_player_idx % PLAYER_COLORS.size()]
	var turn_node: Label = hud_panel.get_node("HUDTurn")
	turn_node.text = "🎮 Jugador " + str(active_player_idx + 1) + "\nTirada #" + str(players_turns[active_player_idx])
	turn_node.add_theme_color_override("font_color", color.lightened(0.3))

func update_timer_display() -> void:
	var minutes: int = floor(game_time / 60.0)
	var seconds: float = fmod(game_time, 60.0)
	var timer_node: Label = hud_panel.get_node("HUDTimer")
	timer_node.text = "⏱ " + "%02d:%05.2f" % [minutes, seconds]

# region LÓGICA DE JUEGO

func roll_dice() -> void:
	if is_moving: return
	
	AudioManager.play_sfx(sfx_dice_roll)
	
	players_turns[active_player_idx] += 1
	update_ui_turn() 
	
	dice_btn.disabled = true
	var roll: int = randi_range(1, 6)
	
	# Animación del dado
	_animate_dice_roll(roll)
	
	move_active_player(roll)

func _animate_dice_roll(final_value: int) -> void:
	var dice_faces: Array[String] = ["⚀", "⚁", "⚂", "⚃", "⚄", "⚅"]
	var tween: Tween = create_tween()
	
	# Mostrar caras aleatorias rápidamente
	for i in range(8):
		var random_face: String = dice_faces[randi() % 6]
		tween.tween_callback(func(): dice_result_lbl.text = random_face + " ...")
		tween.tween_interval(0.06)
	
	# Mostrar resultado final con bounce
	tween.tween_callback(func():
		dice_result_lbl.text = dice_faces[final_value - 1] + "  ¡" + str(final_value) + "!"
		dice_result_lbl.add_theme_font_size_override("font_size", 26)
	)
	tween.tween_interval(0.15)
	tween.tween_callback(func():
		dice_result_lbl.add_theme_font_size_override("font_size", 20)
	)

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
		var jump_to: int = special_movements[new_index]
		var offset: Vector2 = Vector2(active_player_idx * 10, active_player_idx * 5)
		
		if jump_to > new_index:
			AudioManager.play_sfx(sfx_ladder) 
			_show_feedback("⬆ ¡Escalera!", Color(0.3, 1.0, 0.5))
		else:
			AudioManager.play_sfx(sfx_slide)  
			_show_feedback("⬇ ¡Bajada!", Color(1.0, 0.5, 0.3))
		
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
	
	# Animación de entrada del panel
	quiz_panel.modulate = Color(1, 1, 1, 0)
	quiz_panel.scale = Vector2(0.9, 0.9)
	quiz_panel.pivot_offset = quiz_panel.size / 2.0
	quiz_panel.show()
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(quiz_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_property(quiz_panel, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK)
	
	quiz_lbl.text = "📝 Pregunta para J" + str(active_player_idx + 1) + ":\n\n" + data["q"]
	
	var options: Array = data["options"]
	var correct_idx: int = data["correct"]
	var buttons: Array = [$CanvasLayer/PanelQuiz/BtnOp1, $CanvasLayer/PanelQuiz/BtnOp2, $CanvasLayer/PanelQuiz/BtnOp3]
	
	for i in range(buttons.size()):
		if i < options.size():
			var letter: String = ["A", "B", "C"][i]
			buttons[i].text = letter + ")  " + options[i]
			buttons[i].show()
			
			if buttons[i].pressed.is_connected(_on_answer_selected):
				buttons[i].pressed.disconnect(_on_answer_selected)
			buttons[i].pressed.connect(_on_answer_selected.bind(i == correct_idx))
		else:
			buttons[i].hide()

func _on_answer_selected(is_correct: bool) -> void:
	# Animación de salida del quiz
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(quiz_panel, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_property(quiz_panel, "scale", Vector2(0.95, 0.95), 0.2)
	await tween.finished
	quiz_panel.hide()
	quiz_panel.scale = Vector2(1, 1)
	
	if is_correct:
		AudioManager.play_sfx(sfx_correct) 
		_show_feedback("✅ ¡Correcto!\nTira otra vez.", Color(0.3, 1.0, 0.5))
		is_moving = false
		dice_btn.disabled = false
	else:
		AudioManager.play_sfx(sfx_wrong)   
		_show_feedback("❌ Incorrecto", Color(1.0, 0.4, 0.4))
		end_turn()

func _show_feedback(text: String, color: Color) -> void:
	feedback_lbl.text = text
	feedback_lbl.add_theme_color_override("font_color", color)
	feedback_lbl.modulate = Color(1, 1, 1, 0)
	
	var tween: Tween = create_tween()
	tween.tween_property(feedback_lbl, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_interval(2.5)
	tween.tween_property(feedback_lbl, "modulate", Color(1, 1, 1, 0), 0.5)

func handle_victory() -> void:
	AudioManager.play_sfx(sfx_win) 
	AudioManager.stop_music()       
	
	_show_feedback("🏆 ¡JUGADOR " + str(active_player_idx + 1) + " GANA! 🎉", Color(1, 0.85, 0.2))
	dice_result_lbl.text = "🏆 ¡Victoria!"
	
	is_moving = false
	dice_btn.disabled = true
	
	# Esperar un momento antes de mostrar el menú final
	await get_tree().create_timer(1.5).timeout
	
	var end_game_menu: Node = preload("res://ui/EndGameMenu.tscn").instantiate()
	
	end_game_menu.final_time = game_time
	end_game_menu.final_turns = players_turns[active_player_idx]
	
	add_child(end_game_menu)
	set_process(false)

func setup_quiz_buttons() -> void:
	pass

# endregion
