extends GdUnitTestSuite

func test_umbrales_de_ataque_son_coherentes() -> void:
	assert_float(GameConfig.UMBRAL_ATAQUE_ENTRADA).is_greater(GameConfig.UMBRAL_ATAQUE_SALIDA)

func test_umbrales_de_huida_son_coherentes() -> void:
	assert_float(GameConfig.UMBRAL_HUIDA_ENTRADA).is_less(GameConfig.UMBRAL_HUIDA_SALIDA)

func test_impactos_para_absorber() -> void:
	assert_int(GameConfig.IMPACTOS_PARA_ABSORBER).is_equal(3)

func test_vida_espora() -> void:
	assert_float(GameConfig.VIDA_ESPORA).is_equal(3.5)

func test_hordas_tiene_cinco_elementos() -> void:
	assert_array(GameConfig.HORDAS).has_size(5)
