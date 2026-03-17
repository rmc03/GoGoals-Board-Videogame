extends Node2D

const PauseMenuUIScript := preload("res://scripts/UI/Game/PauseMenu.gd")

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

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var dice_btn: Button = $CanvasLayer/BotonDado
@onready var result_lbl: Label = $CanvasLayer/LabelResultado
@onready var quiz_panel: Panel = $CanvasLayer/PanelQuiz
@onready var quiz_lbl: Label = $CanvasLayer/PanelQuiz/LabelPregunta
@onready var btn_op_1: Button = $CanvasLayer/PanelQuiz/BtnOp1
@onready var btn_op_2: Button = $CanvasLayer/PanelQuiz/BtnOp2
@onready var btn_op_3: Button = $CanvasLayer/PanelQuiz/BtnOp3
@onready var timer_lbl: Label = $CanvasLayer/LabelCronometro
@onready var turn_lbl: Label = $CanvasLayer/LabelTurnos

var game_manager: GameManager
var game_hud: GameHUD
var quiz_ui: QuizPanelUI
var pause_menu: Node

func _ready() -> void:
	randomize()
	_create_game_manager()
	_create_hud()
	_create_quiz_ui()
	_create_pause_menu()
	_connect_flow()
	game_manager.initialize_game(board_tiles, GameData.players_count, player_textures)

func _create_game_manager() -> void:
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	add_child(game_manager)
	game_manager.configure_audio(
		music_background,
		sfx_dice_roll,
		sfx_step,
		sfx_ladder,
		sfx_slide,
		sfx_correct,
		sfx_wrong,
		sfx_win
	)

func _create_hud() -> void:
	game_hud = GameHUD.new()
	game_hud.name = "GameHUD"
	add_child(game_hud)
	game_hud.setup(canvas_layer, dice_btn, timer_lbl, turn_lbl, result_lbl, game_manager)

func _create_quiz_ui() -> void:
	quiz_ui = QuizPanelUI.new()
	quiz_ui.name = "QuizPanelUI"
	add_child(quiz_ui)
	var answer_buttons: Array[Button] = [btn_op_1, btn_op_2, btn_op_3]
	quiz_ui.setup(quiz_panel, quiz_lbl, answer_buttons)

func _create_pause_menu() -> void:
	pause_menu = PauseMenuUIScript.new()
	pause_menu.name = "PauseMenuUI"
	add_child(pause_menu)
	pause_menu.setup(canvas_layer)

func _connect_flow() -> void:
	game_hud.dice_requested.connect(_on_dice_requested)
	game_hud.pause_requested.connect(_on_pause_requested)
	quiz_ui.answer_selected.connect(_on_answer_selected)
	game_manager.quiz_requested.connect(_on_quiz_requested)
	game_manager.victory.connect(_on_victory)
	game_manager.pause_state_changed.connect(_on_pause_state_changed)
	pause_menu.resume_requested.connect(_on_pause_requested)
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.menu_requested.connect(_on_menu_requested)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_on_pause_requested()
		get_viewport().set_input_as_handled()

func _on_dice_requested() -> void:
	game_manager.roll_dice()

func _on_quiz_requested(player_index: int, ods_id: int, question_data: Dictionary) -> void:
	if game_hud:
		game_hud.set_quiz_active(true)
	quiz_ui.show_question(question_data, player_index, ods_id)

func _on_answer_selected(answer_result: Dictionary) -> void:
	if game_hud:
		game_hud.set_quiz_active(false)
	game_manager.answer_quiz(answer_result)

func _on_pause_requested() -> void:
	game_manager.toggle_pause()

func _on_pause_state_changed(paused: bool) -> void:
	if paused:
		pause_menu.show_menu()
	else:
		pause_menu.hide_menu()

func _on_restart_requested() -> void:
	AudioManager.stop_music()
	get_tree().reload_current_scene()

func _on_menu_requested() -> void:
	AudioManager.stop_music()
	get_tree().change_scene_to_file(Constants.SCENE_MENU_PRINCIPAL)

func _on_victory(_player_index: int, time: float, turns: int) -> void:
	_on_pause_state_changed(false)
	await get_tree().create_timer(1.5).timeout
	var end_game_menu = preload("res://ui/EndGameMenu.tscn").instantiate()
	end_game_menu.final_time = time
	end_game_menu.final_turns = turns
	end_game_menu.winner_index = _player_index
	end_game_menu.final_summary = game_manager.get_match_summary(_player_index)
	add_child(end_game_menu)
