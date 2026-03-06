extends Node
class_name GameManager

var board: BoardEntity
var players: Array[PlayerEntity] = []
var board_config: BoardConfig
var game_state: GameState

var player_scene: PackedScene = preload("res://scenes/FichaJugador.tscn")

var is_moving: bool = false
var is_quiz_active: bool = false
var current_quiz_question: Dictionary = {}
var current_quiz_player_idx: int = -1
var match_stats: Dictionary = {}

var music_background: AudioStream
var sfx_dice_roll: AudioStream
var sfx_step: AudioStream
var sfx_ladder: AudioStream
var sfx_slide: AudioStream
var sfx_correct: AudioStream
var sfx_wrong: AudioStream
var sfx_win: AudioStream

signal game_initialized(player_count: int)
signal turn_started(player_index: int, turn_count: int)
signal movement_started(player_index: int)
signal movement_finished(player_index: int, tile_index: int)
signal dice_rolled(player_index: int, value: int)
signal input_state_changed(enabled: bool)
signal feedback_requested(text: String, color: Color)
signal quiz_requested(player_index: int, ods_id: int, question_data: Dictionary)
signal victory(player_index: int, time: float, turns: int)
signal game_time_updated(time: float)
signal pause_state_changed(paused: bool)

func _audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")

func _game_data() -> Node:
	return get_node_or_null("/root/GameData")

func _play_music(stream: AudioStream) -> void:
	var audio_manager: Node = _audio_manager()
	if audio_manager and audio_manager.has_method("play_music"):
		audio_manager.play_music(stream)

func _play_sfx(stream: AudioStream, volume_mod: float = 0.0) -> void:
	var audio_manager: Node = _audio_manager()
	if audio_manager and audio_manager.has_method("play_sfx"):
		audio_manager.play_sfx(stream, volume_mod)

func _stop_music() -> void:
	var audio_manager: Node = _audio_manager()
	if audio_manager and audio_manager.has_method("stop_music"):
		audio_manager.stop_music()

func _ready() -> void:
	_ensure_core()
	_reset_quiz_state()
	_reset_match_stats()

func _process(delta: float) -> void:
	if _should_count_time():
		game_state.update_time(delta)
		game_time_updated.emit(game_state.game_time)

func _ensure_core() -> void:
	if board_config == null:
		board_config = BoardConfig.new()

	if game_state == null:
		game_state = GameState.new()
		game_state.name = "GameState"
		add_child(game_state)

func _reset_quiz_state() -> void:
	current_quiz_question.clear()
	current_quiz_player_idx = -1

func _reset_match_stats() -> void:
	match_stats = {
		"correct_answers": 0,
		"incorrect_answers": 0,
		"quizzes_answered": 0,
		"special_tiles_triggered": 0,
		"ladders_taken": 0,
		"slides_taken": 0,
		"pause_count": 0,
		"best_streak": 0,
		"current_streak": 0,
		"unique_ods": [],
		"quiz_history": []
	}

func _ensure_match_stats() -> void:
	if match_stats.is_empty():
		_reset_match_stats()

func configure_audio(
	background_music: AudioStream,
	dice_roll_sfx: AudioStream,
	step_sfx: AudioStream,
	ladder_sfx: AudioStream,
	slide_sfx: AudioStream,
	correct_sfx: AudioStream,
	wrong_sfx: AudioStream,
	win_sfx: AudioStream
) -> void:
	music_background = background_music
	sfx_dice_roll = dice_roll_sfx
	sfx_step = step_sfx
	sfx_ladder = ladder_sfx
	sfx_slide = slide_sfx
	sfx_correct = correct_sfx
	sfx_wrong = wrong_sfx
	sfx_win = win_sfx

func initialize_game(board_nodes: Array[Node2D], player_count: int, textures: Array[Texture2D]) -> void:
	_ensure_core()
	_clear_runtime_nodes()

	board = BoardEntity.new()
	board.name = "Board"
	add_child(board)
	board.load_config(
		board_config.get_ladders(),
		board_config.get_slides(),
		board_config.get_quiz_tiles(),
		board_config.get_ods_visuals()
	)
	board.setup(board_nodes)

	game_state.initialize_game(player_count)
	is_moving = false
	is_quiz_active = false
	_reset_quiz_state()
	_reset_match_stats()
	var game_data: Node = _game_data()
	if game_data and game_data.has_method("reset_question_history"):
		game_data.reset_question_history()

	_create_players(player_count, textures)

	if music_background:
		_play_music(music_background)

	game_time_updated.emit(game_state.game_time)
	turn_started.emit(game_state.active_player_idx(), game_state.get_player_turn_count(game_state.active_player_idx()))
	input_state_changed.emit(true)
	pause_state_changed.emit(false)
	game_initialized.emit(player_count)

func _clear_runtime_nodes() -> void:
	_reset_quiz_state()

	if board != null and is_instance_valid(board):
		board.queue_free()
	board = null

	for player in players:
		if player != null and is_instance_valid(player):
			player.queue_free()
	players.clear()

func _create_players(count: int, textures: Array[Texture2D]) -> void:
	for i in range(count):
		var player: PlayerEntity = player_scene.instantiate()
		player.name = "Player_%d" % i
		add_child(player)
		player.set_player_index(i)

		var player_texture: Texture2D = null
		if i < textures.size():
			player_texture = textures[i]

		player.setup(board.get_tile_position(0), player_texture)
		players.append(player)

func roll_dice() -> int:
	if not can_player_roll():
		return -1

	var player_idx: int = game_state.active_player_idx()
	var roll: int = randi_range(Constants.DICE_MIN, Constants.DICE_MAX)

	game_state.increment_turn_count(player_idx)

	if sfx_dice_roll:
		_play_sfx(sfx_dice_roll)

	dice_rolled.emit(player_idx, roll)
	turn_started.emit(player_idx, game_state.get_player_turn_count(player_idx))
	input_state_changed.emit(false)

	move_player(roll)
	return roll

func move_player(steps: int) -> void:
	is_moving = true
	game_state.is_moving = true

	var player_idx: int = game_state.active_player_idx()
	var current_pos: int = game_state.get_player_position(player_idx)
	var path: Array[int] = board.calculate_path(current_pos, steps)

	movement_started.emit(player_idx)
	_animate_movement(players[player_idx], path)

func _animate_movement(player: PlayerEntity, path: Array[int]) -> void:
	var tween: Tween = create_tween()
	var player_idx: int = player.player_index

	for tile_idx in path:
		var board_pos: Vector2 = board.get_tile_position(tile_idx)
		var target_pos: Vector2 = player.calculate_display_position(board_pos)
		tween.tween_property(player, "position", target_pos, Constants.MOVEMENT_TWEEN_DURATION)
		tween.tween_callback(func(): _play_step_sfx())

	var destination: int = path[-1] if not path.is_empty() else game_state.get_player_position(player_idx)
	tween.tween_callback(func(): _on_movement_finished(player_idx, destination))

func _play_step_sfx() -> void:
	if sfx_step:
		_play_sfx(sfx_step, Constants.SFX_STEP_VOLUME_MOD)

func _on_movement_finished(player_idx: int, new_index: int) -> void:
	game_state.set_player_position(player_idx, new_index)
	movement_finished.emit(player_idx, new_index)
	_check_tile(player_idx, new_index)

func _check_tile(player_idx: int, tile_index: int) -> void:
	var tile: TileEntity = board.get_tile(tile_index)

	if tile == null:
		_end_turn()
		return

	if tile.is_special():
		_handle_special_tile(player_idx, tile)
		return

	if tile.is_quiz():
		_request_quiz(player_idx, tile.ods_id)
		return

	if tile.is_finish():
		_handle_victory(player_idx)
		return

	_end_turn()

func _handle_special_tile(player_idx: int, tile: TileEntity) -> void:
	_ensure_match_stats()
	var player: PlayerEntity = players[player_idx]
	var target_pos: int = tile.target_position
	var is_ladder: bool = tile.tile_type == TileEntity.TileType.LADDER

	match_stats["special_tiles_triggered"] += 1

	if is_ladder:
		match_stats["ladders_taken"] += 1
		if sfx_ladder:
			_play_sfx(sfx_ladder)
		feedback_requested.emit("⬆ ¡Escalera!", Color(0.3, 1.0, 0.5))
	else:
		match_stats["slides_taken"] += 1
		if sfx_slide:
			_play_sfx(sfx_slide)
		feedback_requested.emit("⬇ ¡Bajada!", Color(1.0, 0.5, 0.3))

	var tween: Tween = create_tween()
	var board_pos: Vector2 = board.get_tile_position(target_pos)
	var target_display_pos: Vector2 = player.calculate_display_position(board_pos)
	tween.tween_property(player, "position", target_display_pos, Constants.SPECIAL_MOVE_TWEEN_DURATION)
	await tween.finished

	game_state.set_player_position(player_idx, target_pos)
	movement_finished.emit(player_idx, target_pos)
	_check_tile(player_idx, target_pos)

func _request_quiz(player_idx: int, ods_id: int) -> void:
	_ensure_match_stats()
	var game_data: Node = _game_data()
	var question_data: Dictionary = {}
	if game_data and game_data.has_method("get_question"):
		question_data = game_data.get_question(ods_id)
	if question_data.is_empty():
		_end_turn()
		return

	is_moving = false
	is_quiz_active = true
	game_state.is_moving = false
	current_quiz_question = question_data.duplicate(true)
	current_quiz_player_idx = player_idx
	if not match_stats["unique_ods"].has(ods_id):
		match_stats["unique_ods"].append(ods_id)
	quiz_requested.emit(player_idx, ods_id, question_data)

func _normalize_quiz_result(answer_result: Variant) -> Dictionary:
	if answer_result is Dictionary:
		return answer_result.duplicate(true)

	return {
		"is_correct": bool(answer_result)
	}

func _record_quiz_result(result_data: Dictionary) -> void:
	_ensure_match_stats()
	match_stats["quizzes_answered"] += 1

	var is_correct: bool = bool(result_data.get("is_correct", false))
	if is_correct:
		match_stats["correct_answers"] += 1
		match_stats["current_streak"] += 1
		match_stats["best_streak"] = maxi(match_stats["best_streak"], match_stats["current_streak"])
	else:
		match_stats["incorrect_answers"] += 1
		match_stats["current_streak"] = 0

	match_stats["quiz_history"].append(result_data.duplicate(true))

func answer_quiz(answer_result: Variant) -> void:
	if not is_quiz_active or is_paused():
		return

	var result_data: Dictionary = _normalize_quiz_result(answer_result)
	var is_correct: bool = bool(result_data.get("is_correct", false))

	result_data["player_index"] = current_quiz_player_idx
	result_data["ods_id"] = int(current_quiz_question.get("ods", result_data.get("ods_id", -1)))
	result_data["question"] = str(current_quiz_question.get("q", result_data.get("question", "")))
	result_data["explanation"] = str(current_quiz_question.get("explanation", result_data.get("explanation", "")))
	result_data["correct_text"] = str(current_quiz_question.get("correct_text", result_data.get("correct_text", "")))
	_record_quiz_result(result_data)

	is_quiz_active = false
	is_moving = false
	game_state.is_moving = false
	_reset_quiz_state()

	if is_correct:
		if sfx_correct:
			_play_sfx(sfx_correct)
		feedback_requested.emit("✅ ¡Correcto!\nTira otra vez.", Color(0.3, 1.0, 0.5))
		input_state_changed.emit(true)
	else:
		if sfx_wrong:
			_play_sfx(sfx_wrong)
		feedback_requested.emit("❌ Incorrecto", Color(1.0, 0.4, 0.4))
		_end_turn()

func _end_turn() -> void:
	is_moving = false
	is_quiz_active = false
	game_state.is_moving = false
	game_state.advance_turn()
	turn_started.emit(game_state.active_player_idx(), game_state.get_player_turn_count(game_state.active_player_idx()))
	input_state_changed.emit(true)

func _handle_victory(player_idx: int) -> void:
	is_moving = false
	is_quiz_active = false
	game_state.is_moving = false
	_reset_quiz_state()
	game_state.set_phase(GameState.GamePhase.GAME_OVER)

	if sfx_win:
		_play_sfx(sfx_win)
	_stop_music()

	var turns: int = game_state.get_player_turn_count(player_idx)
	feedback_requested.emit("🏆 ¡JUGADOR %d GANA! 🎉" % [player_idx + 1], Color(1.0, 0.85, 0.2))
	input_state_changed.emit(false)
	victory.emit(player_idx, game_state.game_time, turns)

func pause_game() -> bool:
	if game_state == null or game_state.is_game_over() or is_moving:
		return false

	_ensure_match_stats()

	if game_state.current_phase == GameState.GamePhase.PAUSED:
		return true

	game_state.set_phase(GameState.GamePhase.PAUSED)
	input_state_changed.emit(false)
	match_stats["pause_count"] += 1
	pause_state_changed.emit(true)
	return true

func resume_game() -> bool:
	if game_state == null or game_state.current_phase != GameState.GamePhase.PAUSED:
		return false

	game_state.set_phase(GameState.GamePhase.PLAYING)
	input_state_changed.emit(not is_moving and not is_quiz_active)
	pause_state_changed.emit(false)
	return true

func toggle_pause() -> bool:
	if is_paused():
		return resume_game()
	return pause_game()

func is_paused() -> bool:
	return game_state != null and game_state.current_phase == GameState.GamePhase.PAUSED

func get_match_summary(winner_idx: int = -1) -> Dictionary:
	_ensure_match_stats()
	var quizzes_answered: int = int(match_stats.get("quizzes_answered", 0))
	var correct_answers: int = int(match_stats.get("correct_answers", 0))
	var accuracy: float = 0.0
	if quizzes_answered > 0:
		accuracy = (float(correct_answers) / float(quizzes_answered)) * 100.0

	var unique_ods: Array = match_stats.get("unique_ods", []).duplicate()
	unique_ods.sort()

	return {
		"winner_index": winner_idx,
		"winner_name": "Jugador %d" % [winner_idx + 1] if winner_idx >= 0 else "",
		"time": game_state.game_time if game_state != null else 0.0,
		"turns": game_state.get_player_turn_count(winner_idx) if game_state != null and winner_idx >= 0 else 0,
		"correct_answers": correct_answers,
		"incorrect_answers": int(match_stats.get("incorrect_answers", 0)),
		"quizzes_answered": quizzes_answered,
		"accuracy": accuracy,
		"special_tiles_triggered": int(match_stats.get("special_tiles_triggered", 0)),
		"ladders_taken": int(match_stats.get("ladders_taken", 0)),
		"slides_taken": int(match_stats.get("slides_taken", 0)),
		"pause_count": int(match_stats.get("pause_count", 0)),
		"best_streak": int(match_stats.get("best_streak", 0)),
		"unique_ods": unique_ods,
		"unique_ods_count": unique_ods.size(),
		"player_turns": game_state.players_turns.duplicate() if game_state != null else [],
		"quiz_history": match_stats.get("quiz_history", []).duplicate(true)
	}

func _should_count_time() -> bool:
	return game_state != null and game_state.is_playing() and not is_moving and not is_quiz_active

func can_player_roll() -> bool:
	return game_state != null and game_state.is_playing() and not is_moving and not is_quiz_active and not players.is_empty()

func get_active_player() -> PlayerEntity:
	var idx: int = game_state.active_player_idx()
	if idx >= 0 and idx < players.size():
		return players[idx]
	return null

func get_player_count() -> int:
	return players.size()

func is_player_moving() -> bool:
	return is_moving
