extends GdUnitTestSuite

# Se llaman funciones estaticas, sin instanciar nodos ni depender del arbol.
const EsporaScript = preload("res://entities/spore/spore.gd")
const JugadorScript = preload("res://entities/player/player.gd")
const NpcScript = preload("res://entities/npc/npc.gd")

func test_direccion_horizontal_aplana_y_normaliza() -> void:
	var resultado: Vector3 = EsporaScript.direccion_horizontal(Vector3(3.0, 7.0, 4.0))
	assert_float(resultado.y).is_equal(0.0)
	assert_float(resultado.length()).is_equal_approx(1.0, 0.0001)
	assert_float(resultado.z).is_greater(0.0)

func test_direccion_horizontal_cero_sigue_cero() -> void:
	assert_vector(EsporaScript.direccion_horizontal(Vector3.ZERO)).is_equal(Vector3.ZERO)
	assert_vector(EsporaScript.direccion_horizontal(Vector3(0.0, 5.0, 0.0))).is_equal(Vector3.ZERO)

func test_espora_expira_a_los_tres_punto_cinco() -> void:
	assert_bool(EsporaScript.expira(GameConfig.VIDA_ESPORA - 0.01)).is_false()
	assert_bool(EsporaScript.expira(GameConfig.VIDA_ESPORA)).is_true()
	assert_bool(EsporaScript.expira(GameConfig.VIDA_ESPORA + 0.01)).is_true()

func test_disparo_usa_el_yaw_de_la_camara() -> void:
	var noventa: Basis = Basis(Vector3.UP, deg_to_rad(90.0))
	var direccion: Vector3 = JugadorScript.direccion_disparo_horizontal(noventa)
	assert_float(direccion.y).is_equal(0.0)
	assert_float(direccion.length()).is_equal_approx(1.0, 0.0001)
	# Mirando a +90 grados en Y, -basis.z apunta hacia -X.
	assert_vector(direccion).is_equal_approx(Vector3(-1.0, 0.0, 0.0), Vector3.ONE * 0.0001)

func test_disparo_ignora_el_pitch() -> void:
	var yaw: float = deg_to_rad(35.0)
	var plano: Basis = Basis(Vector3.UP, yaw)
	# Misma direccion horizontal con la camara inclinada hacia arriba y abajo.
	var arriba: Basis = plano * Basis(Vector3.RIGHT, deg_to_rad(-50.0))
	var abajo: Basis = plano * Basis(Vector3.RIGHT, deg_to_rad(50.0))
	var esperado: Vector3 = JugadorScript.direccion_disparo_horizontal(plano)
	assert_vector(JugadorScript.direccion_disparo_horizontal(arriba)).is_equal_approx(esperado, Vector3.ONE * 0.0001)
	assert_vector(JugadorScript.direccion_disparo_horizontal(abajo)).is_equal_approx(esperado, Vector3.ONE * 0.0001)

func test_disparo_con_camara_casi_vertical_no_es_cero() -> void:
	var casi_vertical: Basis = Basis(Vector3.UP, deg_to_rad(20.0)) * Basis(Vector3.RIGHT, deg_to_rad(-89.9))
	var direccion: Vector3 = JugadorScript.direccion_disparo_horizontal(casi_vertical)
	assert_float(direccion.length()).is_equal_approx(1.0, 0.0001)

func test_impacto_cuenta_en_el_umbral_exacto() -> void:
	assert_bool(NpcScript.impacto_cuenta(GameConfig.UMBRAL_ATAQUE_ENTRADA, 1.0)).is_true()

func test_impacto_justo_debajo_del_umbral_no_cuenta() -> void:
	assert_bool(NpcScript.impacto_cuenta(1.09, 1.0)).is_false()
	assert_bool(NpcScript.impacto_cuenta(1.0, 1.0)).is_false()

func test_impacto_de_atacante_mas_chico_no_cuenta() -> void:
	assert_bool(NpcScript.impacto_cuenta(0.6, 1.0)).is_false()
	assert_bool(NpcScript.impacto_cuenta(0.6, 1.8)).is_false()

func test_impacto_de_atacante_mas_grande_cuenta() -> void:
	assert_bool(NpcScript.impacto_cuenta(1.5, 1.0)).is_true()
	assert_bool(NpcScript.impacto_cuenta(0.6, 0.4)).is_true()

func test_impacto_con_tamanio_objetivo_invalido_no_cuenta() -> void:
	assert_bool(NpcScript.impacto_cuenta(1.0, 0.0)).is_false()
	assert_bool(NpcScript.impacto_cuenta(9.0, -1.0)).is_false()
