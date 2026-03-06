extends Node

# ============================================
# SISTEMA DE EVENTOS CENTRALIZADO
# Proporciona comunicación entre componentes
# mediante señales globales
# ============================================

# --- SEÑALES DEL JUEGO ---

# Cuando un jugador tira los dados
# Args: (player_index: int, dice_result: int)
signal dice_rolled(player_index: int, dice_result: int)

# Cuando un jugador comienza a moverse
# Args: (player_index: int, from_pos: int, to_pos: int)
signal player_moving(player_index: int, from_pos: int, to_pos: int)

# Cuando un jugador termina de moverse
# Args: (player_index: int, final_pos: int)
signal player_moved(player_index: int, final_pos: int)

# Cuando cambia el turno
# Args: (player_index: int, turn_number: int)
signal turn_changed(player_index: int, turn_number: int)

# Cuando comienza una pregunta de quiz
# Args: (player_index: int, ods_id: int)
signal quiz_started(player_index: int, ods_id: int)

# Cuando se responde una pregunta (correcto/incorrecto)
# Args: (player_index: int, is_correct: bool)
signal quiz_answered(player_index: int, is_correct: bool)

# Cuando un jugador cae en una casilla especial
# Args: (player_index: int, from_pos: int, to_pos: int, is_ladder: bool)
signal special_tile_triggered(player_index: int, from_pos: int, to_pos: int, is_ladder: bool)

# Cuando un jugador gana la partida
# Args: (player_index: int, time: float, turns: int)
signal game_won(player_index: int, time: float, turns: int)

# Cuando el juego termina (no necesariamente con ganador)
signal game_ended()

# --- SEÑALES DE UI ---

# Cuando el usuario presiona el botón de dados
signal dice_button_pressed()

# Cuando se solicita mostrar el panel de quiz
signal show_quiz_requested(ods_id: int)

# Cuando se solicita ocultar el panel de quiz
signal hide_quiz_requested()

# --- SEÑALES DE DATOS ---

# Cuando las preguntas se han cargado
signal questions_loaded()

# Cuando las preguntas fallan en cargar
signal questions_load_failed(error_message: String)

# --- FUNCIONES HELPER ---

# Emite la señal de dados rolados
func emit_dice_rolled(player_index: int, dice_result: int) -> void:
	dice_rolled.emit(player_index, dice_result)

# Emite la señal de turno cambiado
func emit_turn_changed(player_index: int, turn_number: int) -> void:
	turn_changed.emit(player_index, turn_number)

# Emite la señal de quiz iniciado
func emit_quiz_started(player_index: int, ods_id: int) -> void:
	quiz_started.emit(player_index, ods_id)

# Emite la señal de quiz respondido
func emit_quiz_answered(player_index: int, is_correct: bool) -> void:
	quiz_answered.emit(player_index, is_correct)

# Emite la señal de jugador movido
func emit_player_moved(player_index: int, final_pos: int) -> void:
	player_moved.emit(player_index, final_pos)

# Emite la señal de victoria
func emit_game_won(player_index: int, time: float, turns: int) -> void:
	game_won.emit(player_index, time, turns)

# Emite la señal de juego terminado
func emit_game_ended() -> void:
	game_ended.emit()

# Emite la señal de casilla especial
func emit_special_tile_triggered(player_index: int, from_pos: int, to_pos: int, is_ladder: bool) -> void:
	special_tile_triggered.emit(player_index, from_pos, to_pos, is_ladder)
