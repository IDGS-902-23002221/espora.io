extends GdUnitTestSuite

const GameManagerScript = preload("res://core/game_manager.gd")

func _crear() -> Node:
	var gm: Node = GameManagerScript.new()
	add_child(gm)
	return gm

func test_estado_inicial_menu() -> void:
	var gm: Node = _crear()
	assert_int(gm.get("estado_partida")).is_equal(GameManagerScript.EstadoPartida.MENU)
	assert_bool(gm.call("esta_jugando")).is_false()
	gm.free()

func test_iniciar_pausar_reanudar() -> void:
	var gm: Node = _crear()
	gm.call("iniciar_partida")
	assert_bool(gm.call("esta_jugando")).is_true()
	gm.call("pausar")
	assert_bool(gm.call("esta_jugando")).is_false()
	assert_int(gm.get("estado_partida")).is_equal(GameManagerScript.EstadoPartida.PAUSADO)
	gm.call("reanudar")
	assert_bool(gm.call("esta_jugando")).is_true()
	gm.free()

func test_reiniciar_vuelve_a_menu() -> void:
	var gm: Node = _crear()
	gm.call("iniciar_partida")
	gm.call("reiniciar")
	assert_int(gm.get("estado_partida")).is_equal(GameManagerScript.EstadoPartida.MENU)
	assert_bool(gm.call("esta_jugando")).is_false()
	gm.free()

func test_skin_por_defecto() -> void:
	var gm: Node = _crear()
	assert_str(str(gm.get("skin_jugador"))).is_equal("clasico")
	gm.free()

func test_terminar_partida() -> void:
	var gm: Node = _crear()
	gm.call("iniciar_partida")
	gm.call("terminar_partida", true)
	assert_int(gm.get("estado_partida")).is_equal(GameManagerScript.EstadoPartida.TERMINADA)
	assert_bool(gm.get("victoria")).is_true()
	gm.free()
