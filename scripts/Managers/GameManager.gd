extends Node
class_name GameManager

var board: BoardEntity
var players: Array[PlayerEntity] = []
var board_config: BoardConfig
var game_state: GameState

var player_scene: PackedScene = preload("res://scenes/FichaJugador.tscn")

var is_moving: bool = false
var is_quiz_active: bool = false

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

func _ready() -> void:
	_ensure_core()

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
	board.load_config(board_config.get_ladders(), board_config.get_slides(), board_config.get_quiz_tiles())
	board.setup(board_nodes)

	game_state.initialize_game(player_count)
	is_moving = false
	is_quiz_active = false

	_create_players(player_count, textures)

	if music_background:
		AudioManager.play_music(music_background)

	game_time_updated.emit(game_state.game_time)
	turn_started.emit(game_state.active_player_idx(), game_state.get_player_turn_count(game_state.active_player_idx()))
	input_state_changed.emit(true)
	game_initialized.emit(player_count)

func _clear_runtime_nodes() -> void:
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
		AudioManager.play_sfx(sfx_dice_roll)

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
		AudioManager.play_sfx(sfx_step, Constants.SFX_STEP_VOLUME_MOD)

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
	var player: PlayerEntity = players[player_idx]
	var target_pos: int = tile.target_position
	var is_ladder: bool = tile.tile_type == TileEntity.TileType.LADDER

	if is_ladder:
		if sfx_ladder:
			AudioManager.play_sfx(sfx_ladder)
		feedback_requested.emit("⬆ ¡Escalera!", Color(0.3, 1.0, 0.5))
	else:
		if sfx_slide:
			AudioManager.play_sfx(sfx_slide)
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
	var question_data: Dictionary = GameData.get_question(ods_id)
	if question_data.is_empty():
		_end_turn()
		return

	is_moving = false
	is_quiz_active = true
	game_state.is_moving = false
	quiz_requested.emit(player_idx, ods_id, question_data)

func answer_quiz(is_correct: bool) -> void:
	if not is_quiz_active:
		return

	is_quiz_active = false
	is_moving = false
	game_state.is_moving = false

	if is_correct:
		if sfx_correct:
			AudioManager.play_sfx(sfx_correct)
		feedback_requested.emit("✅ ¡Correcto!\nTira otra vez.", Color(0.3, 1.0, 0.5))
		input_state_changed.emit(true)
	else:
		if sfx_wrong:
			AudioManager.play_sfx(sfx_wrong)
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
	game_state.set_phase(GameState.GamePhase.GAME_OVER)

	if sfx_win:
		AudioManager.play_sfx(sfx_win)
	AudioManager.stop_music()

	var turns: int = game_state.get_player_turn_count(player_idx)
	feedback_requested.emit("🏆 ¡JUGADOR %d GANA! 🎉" % [player_idx + 1], Color(1.0, 0.85, 0.2))
	input_state_changed.emit(false)
	victory.emit(player_idx, game_state.game_time, turns)

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
