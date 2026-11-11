extends GdUnitTestSuite

const CamaraOrbit = preload("res://entities/player/camera_orbit.gd")

func test_delta_dentro_del_limite_no_cambia() -> void:
	var relativo: Vector2 = Vector2(40.0, -30.0)
	assert_vector(CamaraOrbit.limitar_delta(relativo, 150.0)).is_equal(relativo)

func test_delta_exacto_al_limite_no_cambia() -> void:
	assert_vector(CamaraOrbit.limitar_delta(Vector2(150.0, 0.0), 150.0)).is_equal(Vector2(150.0, 0.0))

func test_delta_grande_se_recorta_al_maximo() -> void:
	var limitado: Vector2 = CamaraOrbit.limitar_delta(Vector2(600.0, 0.0), 150.0)
	assert_float(limitado.length()).is_equal_approx(150.0, 0.0001)

func test_delta_grande_conserva_la_direccion() -> void:
	var limitado: Vector2 = CamaraOrbit.limitar_delta(Vector2(300.0, -400.0), 150.0)
	assert_vector(limitado.normalized()).is_equal_approx(Vector2(0.6, -0.8), Vector2.ONE * 0.0001)

func test_delta_cero_sigue_cero() -> void:
	assert_vector(CamaraOrbit.limitar_delta(Vector2.ZERO, 150.0)).is_equal(Vector2.ZERO)

func test_limite_cero_anula_el_movimiento() -> void:
	assert_vector(CamaraOrbit.limitar_delta(Vector2(10.0, 10.0), 0.0)).is_equal(Vector2.ZERO)
