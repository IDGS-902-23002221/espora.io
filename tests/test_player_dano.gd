extends GdUnitTestSuite

const EscenaJugador = preload("res://entities/player/player.tscn")

func test_jugador_necesita_seis_impactos_por_intento() -> void:
	var jugador: Node3D = EscenaJugador.instantiate() as Node3D
	add_child(jugador)
	await get_tree().process_frame
	var gm: Node = get_node_or_null("/root/GameManager")
	assert_object(gm).is_not_null()
	gm.call("iniciar_partida")
	var progreso: Puntaje = gm.get("progreso")
	# Simula la conexion del controlador de partida.
	jugador.connect("absorbido", func() -> void: progreso.perder_intento())
	assert_int(progreso.intentos).is_equal(3)

	# Primer intento: 6 golpes (2 por hoja).
	for i in 5:
		jugador.call("recibir_impacto", 2.0, null)
	assert_int(progreso.intentos).is_equal(3)
	jugador.call("recibir_impacto", 2.0, null)
	await get_tree().process_frame
	assert_int(progreso.intentos).is_equal(2)
	jugador.call("_avanzar_reaparicion", 10.0)

	# Segundo intento: otros 6.
	for i in 6:
		jugador.call("recibir_impacto", 2.0, null)
	await get_tree().process_frame
	assert_int(progreso.intentos).is_equal(1)
	jugador.free()
