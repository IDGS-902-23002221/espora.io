extends GdUnitTestSuite

const SpawnerScript = preload("res://world/nutrient_spawner.gd")
const NpcScript = preload("res://entities/npc/npc.gd")

func test_antes_de_50s_solo_azules() -> void:
	assert_bool(SpawnerScript.toca_especial(49.9, 20, 0)).is_false()

func test_despues_de_50s_busca_el_60() -> void:
	assert_bool(SpawnerScript.toca_especial(50.0, 0, 0)).is_true()
	assert_bool(SpawnerScript.toca_especial(50.0, 10, 3)).is_true()
	assert_bool(SpawnerScript.toca_especial(50.0, 10, 4)).is_true()
	assert_bool(SpawnerScript.toca_especial(50.0, 10, 6)).is_false()
	assert_bool(SpawnerScript.toca_especial(50.0, 100, 61)).is_false()

func test_npc_acelera_con_espora_veloz() -> void:
	assert_float(NpcScript.multiplicador_velocidad(0.0)).is_equal_approx(1.0, 0.0001)
	assert_float(NpcScript.multiplicador_velocidad(2.0)).is_equal_approx(
		GameConfig.MULT_VELOCIDAD_ESPORA_VELOZ, 0.0001
	)

func test_raiz_frena_al_npc() -> void:
	assert_float(NpcScript.multiplicador_raiz(0.0)).is_equal_approx(1.0, 0.0001)
	assert_float(NpcScript.multiplicador_raiz(3.0)).is_equal_approx(0.35, 0.0001)
