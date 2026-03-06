extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	randomize()
	_run_all_tests()
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		printerr("TEST FAILURES: %d" % failures.size())
		for failure in failures:
			printerr("- %s" % failure)
		quit(1)

func _run_all_tests() -> void:
	_test_game_state_turn_rotation()
	_test_board_bounce_path()
	_test_question_cycle_without_repeats()
	_test_game_manager_pause_resume()

func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s | actual=%s expected=%s" % [message, str(actual), str(expected)])

func _test_game_state_turn_rotation() -> void:
	var state := GameState.new()
	state.initialize_game(3)
	state.increment_turn_count(0)
	state.advance_turn()

	_assert_equal(state.active_player_idx(), 1, "GameState debe avanzar al siguiente jugador")
	_assert_equal(state.get_player_turn_count(0), 1, "GameState no debe perder conteo de tiradas del jugador actual")
	_assert_equal(state.get_player_turn_count(1), 0, "GameState no debe incrementar turnos del siguiente jugador al rotar")
	state.free()

func _test_board_bounce_path() -> void:
	var board := BoardEntity.new()
	var nodes: Array[Node2D] = []
	for i in range(63):
		var tile := Node2D.new()
		tile.position = Vector2(i * 16, 0)
		nodes.append(tile)

	board.load_config({}, {}, {})
	board.setup(nodes)

	var path: Array[int] = board.calculate_path(60, 4)
	_assert_equal(path, [61, 62, 61, 60], "BoardEntity debe rebotar correctamente al pasarse de la meta")
	board.free()
	for tile in nodes:
		tile.free()

func _test_question_cycle_without_repeats() -> void:
	var data := GameDataGlobal.new()
	data.load_questions()
	data.reset_question_history()

	var questions_for_ods: Array = data.questions_db.get("1", [])
	_assert_true(not questions_for_ods.is_empty(), "GameData debe cargar preguntas para ODS 1")

	var seen_indexes: Dictionary = {}
	for _i in range(questions_for_ods.size()):
		var question: Dictionary = data.get_question(1)
		var question_index: int = int(question.get("question_index", -1))
		_assert_true(question_index >= 0, "GameData debe devolver metadata de indice de pregunta")
		_assert_true(not seen_indexes.has(question_index), "GameData no debe repetir preguntas antes de agotar el ciclo")
		_assert_true(int(question.get("correct", -1)) >= 0, "GameData debe recalcular el indice correcto al preparar opciones")
		_assert_true(not str(question.get("correct_text", "")).is_empty(), "GameData debe exponer el texto correcto para feedback")
		seen_indexes[question_index] = true

	var recycled_question: Dictionary = data.get_question(1)
	_assert_true(not recycled_question.is_empty(), "GameData debe reciclar preguntas cuando se agota el conjunto")
	data.free()

func _test_game_manager_pause_resume() -> void:
	var manager := GameManager.new()
	manager._ready()
	manager.game_state.initialize_game(2)

	_assert_true(manager.pause_game(), "GameManager debe poder pausar una partida activa")
	_assert_true(manager.is_paused(), "GameManager debe reportar estado pausado")
	_assert_true(manager.resume_game(), "GameManager debe poder reanudar una partida pausada")
	_assert_true(manager.game_state.is_playing(), "GameManager debe devolver la fase a PLAYING al reanudar")
	manager.free()
