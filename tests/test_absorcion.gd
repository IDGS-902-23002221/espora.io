extends GdUnitTestSuite

# Logica pura: se llama sin instanciar nodos.
const AbsorcionScript = preload("res://core/absorcion.gd")

func test_crecimiento_por_absorcion_aplica_la_fraccion() -> void:
	# 0.6 * 0.25 = 0.15
	assert_float(AbsorcionScript.crecimiento_por_absorcion(1.0, 0.6)).is_equal_approx(1.15, 0.0001)

func test_crecimiento_por_absorcion_respeta_el_tope() -> void:
	assert_float(AbsorcionScript.crecimiento_por_absorcion(5.9, 2.0)).is_equal_approx(GameConfig.TAMANIO_MAXIMO, 0.0001)

func test_crecimiento_estando_en_el_tope_no_pasa() -> void:
	assert_float(AbsorcionScript.crecimiento_por_absorcion(GameConfig.TAMANIO_MAXIMO, 6.0)).is_equal_approx(GameConfig.TAMANIO_MAXIMO, 0.0001)

func test_crecimiento_con_absorbido_invalido_no_cambia() -> void:
	assert_float(AbsorcionScript.crecimiento_por_absorcion(1.5, 0.0)).is_equal_approx(1.5, 0.0001)
	assert_float(AbsorcionScript.crecimiento_por_absorcion(1.5, -2.0)).is_equal_approx(1.5, 0.0001)

func test_reaparicion_aplica_la_fraccion() -> void:
	# 2.0 * 0.60 = 1.2
	assert_float(AbsorcionScript.tamanio_reaparicion(2.0)).is_equal_approx(1.2, 0.0001)

func test_reaparicion_respeta_el_piso_inicial() -> void:
	# 1.0 * 0.60 = 0.6, pero el piso es TAMANIO_INICIAL.
	assert_float(AbsorcionScript.tamanio_reaparicion(1.0)).is_equal_approx(GameConfig.TAMANIO_INICIAL, 0.0001)

func test_reaparicion_con_absorbido_invalido_queda_en_el_piso() -> void:
	assert_float(AbsorcionScript.tamanio_reaparicion(0.0)).is_equal_approx(GameConfig.TAMANIO_INICIAL, 0.0001)
	assert_float(AbsorcionScript.tamanio_reaparicion(-3.0)).is_equal_approx(GameConfig.TAMANIO_INICIAL, 0.0001)
