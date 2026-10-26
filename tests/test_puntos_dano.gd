extends GdUnitTestSuite

func test_tres_impactos_absorben() -> void:
	var dano: PuntosDano = PuntosDano.new()
	assert_int(dano.puntos).is_equal(GameConfig.IMPACTOS_PARA_ABSORBER)

	dano.recibir_impacto()
	dano.recibir_impacto()
	dano.recibir_impacto()

	assert_int(dano.puntos).is_equal(0)
	assert_int(int(dano.esta_absorbido())).is_equal(1)

func test_absorbido_emite_una_sola_vez() -> void:
	var dano: PuntosDano = PuntosDano.new()
	var emisiones: Array = []
	dano.absorbido.connect(func() -> void: emisiones.append(true))

	for i in 5:
		dano.recibir_impacto()

	assert_int(emisiones.size()).is_equal(1)
	assert_int(dano.puntos).is_equal(0)

func test_impacto_a_3_9_reinicia_y_no_regenera() -> void:
	var dano: PuntosDano = PuntosDano.new()
	dano.recibir_impacto()
	dano.avanzar_tiempo(3.9)
	assert_int(dano.puntos).is_equal(2)

	dano.recibir_impacto()
	dano.avanzar_tiempo(0.1)
	assert_int(dano.puntos).is_equal(1)

func test_regeneracion_justo_en_4_segundos() -> void:
	var antes: PuntosDano = PuntosDano.new()
	antes.recibir_impacto()
	antes.avanzar_tiempo(3.99)
	assert_int(antes.puntos).is_equal(2)

	var justo: PuntosDano = PuntosDano.new()
	justo.recibir_impacto()
	justo.avanzar_tiempo(4.0)
	assert_int(justo.puntos).is_equal(3)

func test_regeneracion_de_a_un_punto() -> void:
	var dano: PuntosDano = PuntosDano.new()
	dano.recibir_impacto()
	dano.recibir_impacto()
	assert_int(dano.puntos).is_equal(1)

	dano.avanzar_tiempo(4.0)
	assert_int(dano.puntos).is_equal(2)

	dano.avanzar_tiempo(4.0)
	assert_int(dano.puntos).is_equal(3)

func test_deltas_pequenos_igual_que_delta_grande() -> void:
	var grande: PuntosDano = PuntosDano.new()
	grande.recibir_impacto()
	grande.avanzar_tiempo(4.0)

	var pequenos: PuntosDano = PuntosDano.new()
	pequenos.recibir_impacto()
	for i in 40:
		pequenos.avanzar_tiempo(0.1)

	assert_int(pequenos.puntos).is_equal(grande.puntos)
	assert_int(grande.puntos).is_equal(GameConfig.IMPACTOS_PARA_ABSORBER)

func test_nunca_supera_el_maximo() -> void:
	var dano: PuntosDano = PuntosDano.new()
	dano.recibir_impacto()
	dano.avanzar_tiempo(100.0)
	assert_int(dano.puntos).is_equal(GameConfig.IMPACTOS_PARA_ABSORBER)

func test_impacto_estando_absorbido_no_cambia_nada() -> void:
	var dano: PuntosDano = PuntosDano.new()
	var cambios: Array = []
	var absorciones: Array = []
	dano.puntos_cambiados.connect(func(restantes: int) -> void: cambios.append(restantes))
	dano.absorbido.connect(func() -> void: absorciones.append(true))

	for i in 5:
		dano.recibir_impacto()

	assert_int(dano.puntos).is_equal(0)
	assert_int(absorciones.size()).is_equal(1)
	assert_int(cambios.size()).is_equal(3)
	assert_int(cambios[0]).is_equal(2)
	assert_int(cambios[1]).is_equal(1)
	assert_int(cambios[2]).is_equal(0)

func test_avanzar_estando_absorbido_no_regenera() -> void:
	var dano: PuntosDano = PuntosDano.new()
	dano.recibir_impacto()
	dano.recibir_impacto()
	dano.recibir_impacto()
	dano.avanzar_tiempo(100.0)
	assert_int(dano.puntos).is_equal(0)

func test_reiniciar_deja_todo_como_al_inicio() -> void:
	var dano: PuntosDano = PuntosDano.new()
	dano.recibir_impacto()
	dano.recibir_impacto()
	dano.reiniciar()

	assert_int(dano.puntos).is_equal(GameConfig.IMPACTOS_PARA_ABSORBER)
	assert_int(int(dano.esta_absorbido())).is_equal(0)

	dano.recibir_impacto()
	dano.avanzar_tiempo(3.99)
	assert_int(dano.puntos).is_equal(2)
	dano.avanzar_tiempo(0.02)
	assert_int(dano.puntos).is_equal(3)

func test_puntos_cambiados_emite_valores_correctos() -> void:
	var dano: PuntosDano = PuntosDano.new()
	var valores: Array = []
	dano.puntos_cambiados.connect(func(restantes: int) -> void: valores.append(restantes))

	dano.recibir_impacto()
	dano.recibir_impacto()
	dano.avanzar_tiempo(4.0)
	dano.reiniciar()

	assert_int(valores.size()).is_equal(4)
	assert_int(valores[0]).is_equal(2)
	assert_int(valores[1]).is_equal(1)
	assert_int(valores[2]).is_equal(2)
	assert_int(valores[3]).is_equal(GameConfig.IMPACTOS_PARA_ABSORBER)
