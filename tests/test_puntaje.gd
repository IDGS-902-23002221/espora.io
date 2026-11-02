extends GdUnitTestSuite

func test_estado_inicial() -> void:
	var p: Puntaje = Puntaje.new()
	assert_int(p.puntos).is_equal(0)
	assert_int(p.intentos).is_equal(GameConfig.INTENTOS_INICIALES)
	assert_int(p.absorbidos).is_equal(0)
	assert_float(p.tamanio_maximo).is_equal_approx(GameConfig.TAMANIO_INICIAL, 0.0001)
	assert_float(p.tiempo).is_equal_approx(0.0, 0.0001)

func test_nutriente_suma_y_emite() -> void:
	var p: Puntaje = Puntaje.new()
	var valores: Array = []
	p.puntaje_cambiado.connect(func(total: int) -> void: valores.append(total))
	p.sumar_nutriente()
	assert_int(p.puntos).is_equal(GameConfig.PUNTOS_POR_NUTRIENTE)
	assert_array(valores).has_size(1)
	assert_int(valores[0]).is_equal(GameConfig.PUNTOS_POR_NUTRIENTE)

func test_absorcion_suma_y_cuenta() -> void:
	var p: Puntaje = Puntaje.new()
	p.registrar_absorcion()
	assert_int(p.puntos).is_equal(GameConfig.PUNTOS_POR_ABSORCION)
	assert_int(p.absorbidos).is_equal(1)

func test_horda_suma() -> void:
	var p: Puntaje = Puntaje.new()
	p.sumar_horda()
	assert_int(p.puntos).is_equal(GameConfig.PUNTOS_POR_HORDA_SUPERADA)

func test_perder_intento_descuenta() -> void:
	var p: Puntaje = Puntaje.new()
	var restantes: Array = []
	p.intentos_cambiados.connect(func(n: int) -> void: restantes.append(n))
	p.perder_intento()
	assert_int(p.intentos).is_equal(2)
	assert_array(restantes).has_size(1)
	assert_int(restantes[0]).is_equal(2)

func test_derrota_exacta_en_cero() -> void:
	var p: Puntaje = Puntaje.new()
	var derrotas: Array = []
	p.derrota.connect(func() -> void: derrotas.append(true))
	p.perder_intento()
	p.perder_intento()
	assert_array(derrotas).is_empty()
	p.perder_intento()
	assert_int(p.intentos).is_equal(0)
	assert_array(derrotas).has_size(1)

func test_no_baja_de_cero_ni_emite_dos_derrotas() -> void:
	var p: Puntaje = Puntaje.new()
	var derrotas: Array = []
	p.derrota.connect(func() -> void: derrotas.append(true))
	for i in 5:
		p.perder_intento()
	assert_int(p.intentos).is_equal(0)
	assert_array(derrotas).has_size(1)

func test_reiniciar_resetea_todo() -> void:
	var p: Puntaje = Puntaje.new()
	p.sumar_nutriente()
	p.registrar_absorcion()
	p.perder_intento()
	p.registrar_tamanio(2.0)
	p.avanzar_tiempo(10.0)
	p.reiniciar()
	assert_int(p.puntos).is_equal(0)
	assert_int(p.intentos).is_equal(GameConfig.INTENTOS_INICIALES)
	assert_int(p.absorbidos).is_equal(0)
	assert_float(p.tamanio_maximo).is_equal_approx(GameConfig.TAMANIO_INICIAL, 0.0001)
	assert_float(p.tiempo).is_equal_approx(0.0, 0.0001)

func test_tamanio_maximo_solo_sube() -> void:
	var p: Puntaje = Puntaje.new()
	p.registrar_tamanio(1.5)
	p.registrar_tamanio(1.2)
	p.registrar_tamanio(2.0)
	assert_float(p.tamanio_maximo).is_equal_approx(2.0, 0.0001)

func test_formatear_tiempo() -> void:
	assert_str(Puntaje.formatear_tiempo(0.0)).is_equal("00:00")
	assert_str(Puntaje.formatear_tiempo(65.0)).is_equal("01:05")
	assert_str(Puntaje.formatear_tiempo(470.0)).is_equal("07:50")
	assert_str(Puntaje.formatear_tiempo(600.0)).is_equal("10:00")
	assert_str(Puntaje.formatear_tiempo(-5.0)).is_equal("00:00")
