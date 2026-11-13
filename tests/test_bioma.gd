extends GdUnitTestSuite

func test_zona_en_los_bordes() -> void:
	assert_int(Bioma.zona_para_radio(0.0)).is_equal(Bioma.Zona.BOSQUE)
	assert_int(Bioma.zona_para_radio(GameConfig.BIOMA_BOSQUE_RADIO - 0.01)).is_equal(Bioma.Zona.BOSQUE)
	assert_int(Bioma.zona_para_radio(GameConfig.BIOMA_BOSQUE_RADIO)).is_equal(Bioma.Zona.PANTANO)
	assert_int(Bioma.zona_para_radio(GameConfig.BIOMA_PANTANO_RADIO - 0.01)).is_equal(Bioma.Zona.PANTANO)
	assert_int(Bioma.zona_para_radio(GameConfig.BIOMA_PANTANO_RADIO)).is_equal(Bioma.Zona.CUEVA)
	assert_int(Bioma.zona_para_radio(GameConfig.RADIO_MAPA)).is_equal(Bioma.Zona.CUEVA)

func test_densidades_por_zona() -> void:
	assert_float(Bioma.densidad(Bioma.Zona.BOSQUE)).is_equal_approx(GameConfig.BIOMA_BOSQUE_DENSIDAD, 0.0001)
	assert_float(Bioma.densidad(Bioma.Zona.PANTANO)).is_equal_approx(GameConfig.BIOMA_PANTANO_DENSIDAD, 0.0001)
	assert_float(Bioma.densidad(Bioma.Zona.CUEVA)).is_equal_approx(GameConfig.BIOMA_CUEVA_DENSIDAD, 0.0001)

func test_radio_en_zona_respeta_los_anillos() -> void:
	assert_float(Bioma.radio_en_zona(Bioma.Zona.BOSQUE, 0.0)).is_equal_approx(0.0, 0.0001)
	assert_float(Bioma.radio_en_zona(Bioma.Zona.BOSQUE, 1.0)).is_equal_approx(GameConfig.BIOMA_BOSQUE_RADIO, 0.0001)
	assert_float(Bioma.radio_en_zona(Bioma.Zona.PANTANO, 0.0)).is_equal_approx(GameConfig.BIOMA_BOSQUE_RADIO, 0.0001)
	assert_float(Bioma.radio_en_zona(Bioma.Zona.PANTANO, 1.0)).is_equal_approx(GameConfig.BIOMA_PANTANO_RADIO, 0.0001)
	assert_float(Bioma.radio_en_zona(Bioma.Zona.CUEVA, 0.0)).is_equal_approx(GameConfig.BIOMA_PANTANO_RADIO, 0.0001)
	assert_float(Bioma.radio_en_zona(Bioma.Zona.CUEVA, 1.0)).is_equal_approx(GameConfig.RADIO_MAPA, 0.0001)

func test_radio_ponderado_cae_en_la_zona_elegida() -> void:
	var p_bosque: float = Bioma.probabilidad_zona(Bioma.Zona.BOSQUE)
	var p_pantano: float = Bioma.probabilidad_zona(Bioma.Zona.PANTANO)
	var p_cueva: float = Bioma.probabilidad_zona(Bioma.Zona.CUEVA)
	assert_int(Bioma.zona_para_radio(Bioma.radio_ponderado(p_bosque * 0.5, 0.5))).is_equal(Bioma.Zona.BOSQUE)
	assert_int(Bioma.zona_para_radio(Bioma.radio_ponderado(p_bosque + p_pantano * 0.5, 0.5))).is_equal(Bioma.Zona.PANTANO)
	assert_int(Bioma.zona_para_radio(Bioma.radio_ponderado(p_bosque + p_pantano + p_cueva * 0.5, 0.5))).is_equal(Bioma.Zona.CUEVA)

func test_probabilidades_suman_uno() -> void:
	var total: float = (
		Bioma.probabilidad_zona(Bioma.Zona.BOSQUE)
		+ Bioma.probabilidad_zona(Bioma.Zona.PANTANO)
		+ Bioma.probabilidad_zona(Bioma.Zona.CUEVA)
	)
	assert_float(total).is_equal_approx(1.0, 0.0001)

func test_pantano_es_la_zona_mas_probable() -> void:
	assert_float(Bioma.probabilidad_zona(Bioma.Zona.PANTANO)).is_greater(Bioma.probabilidad_zona(Bioma.Zona.BOSQUE))
	assert_float(Bioma.probabilidad_zona(Bioma.Zona.BOSQUE)).is_greater(Bioma.probabilidad_zona(Bioma.Zona.CUEVA))

func test_tamanio_npc_respeta_rangos() -> void:
	for zona in [Bioma.Zona.BOSQUE, Bioma.Zona.PANTANO, Bioma.Zona.CUEVA]:
		assert_float(Bioma.tamanio_npc(zona, 1.0, 0.0)).is_equal_approx(Bioma.tamanio_min(zona), 0.0001)
		assert_float(Bioma.tamanio_npc(zona, 1.0, 1.0)).is_equal_approx(Bioma.tamanio_max(zona), 0.0001)

func test_tamanio_npc_aplica_multiplicador_y_tope() -> void:
	assert_float(Bioma.tamanio_npc(Bioma.Zona.BOSQUE, 2.0, 0.0)).is_equal_approx(3.0, 0.0001)
	assert_float(Bioma.tamanio_npc(Bioma.Zona.BOSQUE, 4.0, 1.0)).is_equal_approx(GameConfig.TAMANIO_MAXIMO, 0.0001)

func test_roamer_solo_en_la_cueva() -> void:
	assert_bool(Bioma.es_roamer(Bioma.Zona.BOSQUE, 0.0)).is_false()
	assert_bool(Bioma.es_roamer(Bioma.Zona.PANTANO, 0.0)).is_false()
	assert_bool(Bioma.es_roamer(Bioma.Zona.CUEVA, 0.0)).is_true()
	assert_bool(Bioma.es_roamer(Bioma.Zona.CUEVA, GameConfig.ROAMER_CUEVA_PROBABILIDAD)).is_false()

func test_tamanio_roamer_aplica_multiplicador_y_tope() -> void:
	assert_float(Bioma.tamanio_roamer(1.0)).is_equal_approx(GameConfig.ROAMER_CUEVA_TAMANIO, 0.0001)
	assert_float(Bioma.tamanio_roamer(10.0)).is_equal_approx(GameConfig.TAMANIO_MAXIMO, 0.0001)
