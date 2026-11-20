extends GdUnitTestSuite

const PlayerScript = preload("res://entities/player/player.gd")
const APROX: float = 0.01

func test_yaw_cuerpo_apunta_al_frente() -> void:
	assert_float(PlayerScript.yaw_cuerpo(Vector3(0.0, 0.0, -1.0))).is_equal_approx(0.0, APROX)
	assert_float(absf(PlayerScript.yaw_cuerpo(Vector3(0.0, 0.0, 1.0)))).is_equal_approx(PI, APROX)
	assert_float(PlayerScript.yaw_cuerpo(Vector3(1.0, 0.0, 0.0))).is_equal_approx(-PI / 2.0, APROX)
	assert_float(PlayerScript.yaw_cuerpo(Vector3(-1.0, 0.0, 0.0))).is_equal_approx(PI / 2.0, APROX)

func test_yaw_cuerpo_respeta_desfase_y_direccion_cero() -> void:
	assert_float(PlayerScript.yaw_cuerpo(Vector3.ZERO, 0.3)).is_equal_approx(0.3, APROX)
	assert_float(PlayerScript.yaw_cuerpo(Vector3(0.0, 0.0, -1.0), 0.3)).is_equal_approx(0.3, APROX)

func test_posicion_disparo_rota_con_el_cuerpo() -> void:
	var punto: Vector3 = PlayerScript.POSICION_DISPARO.rotated(Vector3.UP, -PI / 2.0)
	assert_float(absf(punto.x)).is_equal_approx(1.2, APROX)
	assert_float(punto.y).is_equal_approx(0.8, APROX)
	assert_float(punto.z).is_equal_approx(0.0, APROX)
