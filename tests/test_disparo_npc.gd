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
