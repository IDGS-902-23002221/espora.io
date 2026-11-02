extends GdUnitTestSuite

# Se prueban las reglas puras de disparo y el mapeo de capas, sin nodos.
const NpcScript = preload("res://entities/npc/npc.gd")
const EsporaScript = preload("res://entities/spore/spore.gd")

const PERSEGUIR: int = ReglaTamanio.EstadoTamanio.PERSEGUIR
const HUIR: int = ReglaTamanio.EstadoTamanio.HUIR
const NEUTRAL: int = ReglaTamanio.EstadoTamanio.NEUTRAL

func test_dispara_persiguiendo_en_rango_sin_cooldown() -> void:
	assert_bool(NpcScript.puede_disparar(PERSEGUIR, 5.0, 18.0, 0.0)).is_true()

func test_no_dispara_huyendo_ni_neutral() -> void:
	assert_bool(NpcScript.puede_disparar(HUIR, 5.0, 18.0, 0.0)).is_false()
	assert_bool(NpcScript.puede_disparar(NEUTRAL, 5.0, 18.0, 0.0)).is_false()

func test_no_dispara_fuera_del_radio() -> void:
	assert_bool(NpcScript.puede_disparar(PERSEGUIR, 18.01, 18.0, 0.0)).is_false()

func test_dispara_justo_en_el_borde_del_radio() -> void:
	assert_bool(NpcScript.puede_disparar(PERSEGUIR, 18.0, 18.0, 0.0)).is_true()

func test_no_dispara_con_cooldown_activo() -> void:
	assert_bool(NpcScript.puede_disparar(PERSEGUIR, 5.0, 18.0, 0.01)).is_false()
	assert_bool(NpcScript.puede_disparar(PERSEGUIR, 5.0, 18.0, -0.5)).is_true()

func test_capas_de_espora_coinciden_con_el_proyecto() -> void:
	# La espora del jugador pega a NPC (2) y la del NPC al jugador (1).
	assert_int(EsporaScript.CAPA_JUGADOR).is_equal(1)
	assert_int(EsporaScript.CAPA_NPC).is_equal(2)

func test_elegir_objetivo_el_mas_cercano() -> void:
	var candidatos: Array = [
		{"posicion": Vector3(5, 0, 0)},
		{"posicion": Vector3(3, 0, 0)},
		{"posicion": Vector3(8, 0, 0)},
	]
	var elegido: Dictionary = NpcScript.elegir_objetivo(Vector3.ZERO, candidatos, 10.0)
	assert_float(elegido["posicion"].x).is_equal_approx(3.0, 0.0001)

func test_elegir_objetivo_fuera_del_radio() -> void:
	var candidatos: Array = [{"posicion": Vector3(30, 0, 0)}]
	assert_bool(NpcScript.elegir_objetivo(Vector3.ZERO, candidatos, 18.0).is_empty()).is_true()

func test_elegir_objetivo_sin_candidatos() -> void:
	assert_bool(NpcScript.elegir_objetivo(Vector3.ZERO, [], 18.0).is_empty()).is_true()

func test_elegir_objetivo_en_el_borde_del_radio() -> void:
	var candidatos: Array = [{"posicion": Vector3(18, 0, 0)}]
	assert_bool(NpcScript.elegir_objetivo(Vector3.ZERO, candidatos, 18.0).is_empty()).is_false()

func test_punto_intercepcion_objetivo_quieto() -> void:
	var punto: Vector3 = NpcScript.punto_intercepcion(
		Vector3.ZERO, Vector3(5, 1, 0), Vector3.ZERO
	)
	assert_vector(punto).is_equal_approx(Vector3(5, 1, 0), Vector3.ONE * 0.0001)

func test_punto_intercepcion_objetivo_huyendo() -> void:
	# Huye en +X a 5; intercepto a t = 5 / (14 - 5).
	var punto: Vector3 = NpcScript.punto_intercepcion(
		Vector3.ZERO, Vector3(5, 0, 0), Vector3(5, 0, 0)
	)
	assert_float(punto.x).is_equal_approx(5.0 + 5.0 * (5.0 / 9.0), 0.0001)

func test_punto_intercepcion_objetivo_mas_rapido() -> void:
	# Si no hay intercepto posible, apunta a la posicion actual.
	var punto: Vector3 = NpcScript.punto_intercepcion(
		Vector3.ZERO, Vector3(5, 0, 0), Vector3(20, 0, 0)
	)
	assert_vector(punto).is_equal_approx(Vector3(5, 0, 0), Vector3.ONE * 0.0001)
