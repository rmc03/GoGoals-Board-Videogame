extends Node
class_name GameState

enum GamePhase {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_phase: GamePhase = GamePhase.MENU
var players_count: int = 1
var game_time: float = 0.0

var active_player_index: int = 0
var players_turns: Array[int] = []
var players_positions: Array[int] = []

var is_moving: bool = false
var is_dice_rolling: bool = false

signal phase_changed(new_phase: GamePhase)
signal player_position_changed(player_index: int, new_position: int)
signal turn_info_changed(player_index: int, turn_count: int)
signal game_time_updated(new_time: float)

func initialize_game(num_players: int) -> void:
	players_count = num_players
	players_turns.clear()
	players_positions.clear()

	for i in range(num_players):
		players_turns.append(0)
		players_positions.append(0)

	active_player_index = 0
	game_time = 0.0
	is_moving = false
	is_dice_rolling = false
	current_phase = GamePhase.PLAYING
	phase_changed.emit(GamePhase.PLAYING)

func get_current_player() -> int:
	return active_player_index

func get_player_turn_count(player_index: int) -> int:
	if player_index >= 0 and player_index < players_turns.size():
		return players_turns[player_index]
	return 0

func get_player_position(player_index: int) -> int:
	if player_index >= 0 and player_index < players_positions.size():
		return players_positions[player_index]
	return 0

func increment_turn_count(player_index: int) -> void:
	if player_index >= 0 and player_index < players_turns.size():
		players_turns[player_index] += 1
		turn_info_changed.emit(player_index, players_turns[player_index])

func advance_turn() -> void:
	if players_count <= 0:
		return

	active_player_index += 1
	if active_player_index >= players_count:
		active_player_index = 0

	turn_info_changed.emit(active_player_index, get_player_turn_count(active_player_index))

func active_player_idx() -> int:
	return active_player_index

func set_player_position(player_index: int, position: int) -> void:
	if player_index >= 0 and player_index < players_positions.size():
		players_positions[player_index] = position
		player_position_changed.emit(player_index, position)

func get_finish_tile_index() -> int:
	return 62

func update_time(delta: float) -> void:
	if current_phase == GamePhase.PLAYING:
		game_time += delta
		game_time_updated.emit(game_time)

func get_formatted_time() -> String:
	var minutes: int = floor(game_time / 60.0)
	var seconds: float = fmod(game_time, 60.0)
	return "%02d:%05.2f" % [minutes, seconds]

func set_phase(new_phase: GamePhase) -> void:
	current_phase = new_phase
	phase_changed.emit(new_phase)

func is_game_over() -> bool:
	return current_phase == GamePhase.GAME_OVER

func is_playing() -> bool:
	return current_phase == GamePhase.PLAYING

func reset() -> void:
	current_phase = GamePhase.MENU
	players_count = 1
	game_time = 0.0
	active_player_index = 0
	players_turns.clear()
	players_positions.clear()
	is_moving = false
	is_dice_rolling = false
