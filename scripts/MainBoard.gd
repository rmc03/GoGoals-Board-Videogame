extends Node2D

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

func _ready() -> void:
	randomize()
	_create_game_manager()
	_create_hud()
	_create_quiz_ui()
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
	quiz_ui.setup(quiz_panel, quiz_lbl, [btn_op_1, btn_op_2, btn_op_3])

func _connect_flow() -> void:
	game_hud.dice_requested.connect(_on_dice_requested)
	quiz_ui.answer_selected.connect(_on_answer_selected)
	game_manager.quiz_requested.connect(_on_quiz_requested)
	game_manager.victory.connect(_on_victory)

func _on_dice_requested() -> void:
	game_manager.roll_dice()

func _on_quiz_requested(player_index: int, ods_id: int, question_data: Dictionary) -> void:
	quiz_ui.show_question(question_data, player_index, ods_id)

func _on_answer_selected(is_correct: bool) -> void:
	game_manager.answer_quiz(is_correct)

func _on_victory(_player_index: int, time: float, turns: int) -> void:
	await get_tree().create_timer(1.5).timeout
	var end_game_menu: Node = preload("res://ui/EndGameMenu.tscn").instantiate()
	end_game_menu.final_time = time
	end_game_menu.final_turns = turns
	add_child(end_game_menu)
