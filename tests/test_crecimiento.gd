extends GdUnitTestSuite

func test_crecer_suma_el_crecimiento() -> void:
	var esperado: float = GameConfig.TAMANIO_INICIAL + GameConfig.CRECIMIENTO_NUTRIENTE
	assert_float(Crecimiento.crecer(GameConfig.TAMANIO_INICIAL)).is_equal_approx(esperado, 0.0001)

func test_crecer_respeta_el_tope() -> void:
	assert_float(Crecimiento.crecer(GameConfig.TAMANIO_MAXIMO)).is_equal(GameConfig.TAMANIO_MAXIMO)
	assert_float(Crecimiento.crecer(GameConfig.TAMANIO_MAXIMO - 0.01)).is_equal(GameConfig.TAMANIO_MAXIMO)

func test_velocidad_base_al_tamanio_inicial() -> void:
	var base: float = GameConfig.VELOCIDAD_BASE_JUGADOR
	assert_float(Crecimiento.velocidad_por_tamanio(GameConfig.TAMANIO_INICIAL, base)).is_equal_approx(base, 0.0001)

func test_velocidad_baja_al_crecer() -> void:
	var base: float = GameConfig.VELOCIDAD_BASE_JUGADOR
	assert_float(Crecimiento.velocidad_por_tamanio(2.0, base)).is_less(base)

func test_velocidad_respeta_el_piso() -> void:
	var base: float = GameConfig.VELOCIDAD_BASE_JUGADOR
	var minima: float = base * GameConfig.VELOCIDAD_MINIMA_FRACCION
	assert_float(Crecimiento.velocidad_por_tamanio(100.0, base)).is_equal_approx(minima, 0.0001)

func test_velocidad_nunca_sube_al_crecer() -> void:
	var base: float = GameConfig.VELOCIDAD_BASE_JUGADOR
	var anterior: float = Crecimiento.velocidad_por_tamanio(GameConfig.TAMANIO_INICIAL, base)
	for paso in 24:
		var tamanio: float = GameConfig.TAMANIO_INICIAL + 0.25 * float(paso)
		var actual: float = Crecimiento.velocidad_por_tamanio(tamanio, base)
		assert_float(actual).is_less_equal(anterior)
		anterior = actual

func test_velocidad_npc_respeta_el_piso() -> void:
	var base: float = float(Hordas.configuracion(0)["velocidad_npc"])
	var minima: float = base * GameConfig.VELOCIDAD_MINIMA_FRACCION
	var enorme: float = GameConfig.TAMANIO_MAXIMO * 10.0
	assert_float(Crecimiento.velocidad_por_tamanio(enorme, base)).is_equal_approx(minima, 0.0001)

func test_velocidad_usa_el_mismo_factor_para_jugador_y_npc() -> void:
	var tamanio: float = 3.0
	var base_jugador: float = GameConfig.VELOCIDAD_BASE_JUGADOR
	var base_npc: float = float(Hordas.configuracion(0)["velocidad_npc"])
	var factor_jugador: float = Crecimiento.velocidad_por_tamanio(tamanio, base_jugador) / base_jugador
	var factor_npc: float = Crecimiento.velocidad_por_tamanio(tamanio, base_npc) / base_npc
	assert_float(factor_jugador).is_equal_approx(factor_npc, 0.0001)
