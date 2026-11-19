extends GdUnitTestSuite

const SpawnerScript = preload("res://world/powerup_spawner.gd")

func _crear_spawner() -> Node3D:
	var spawner: Node3D = SpawnerScript.new() as Node3D
	add_child(spawner)
	return spawner

func test_espera_en_rango() -> void:
	var spawner: Node3D = _crear_spawner()
	for i in 20:
		var espera: float = float(spawner.call("_siguiente_espera"))
		assert_float(espera).is_greater_equal(GameConfig.INTERVALO_ESPORA_ESCUDO_MIN)
		assert_float(espera).is_less_equal(GameConfig.INTERVALO_ESPORA_ESCUDO_MAX)
	spawner.free()

func test_maximo_un_escudo() -> void:
	var spawner: Node3D = _crear_spawner()
	spawner.set("_espera", 0.0)
	spawner.call("_process", 0.1)
	assert_int(spawner.get_child_count()).is_equal(1)
	assert_bool(bool(spawner.get("_escudo_activo"))).is_true()
	spawner.call("_process", 0.1)
	assert_int(spawner.get_child_count()).is_equal(1)
	spawner.free()
