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
