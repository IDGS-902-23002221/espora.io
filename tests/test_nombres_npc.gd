extends GdUnitTestSuite

const NombresScript = preload("res://core/nombres_npc.gd")

func test_nombre_en_lista() -> void:
	for i in 10:
		var nombre: String = NombresScript.nombre_aleatorio()
		assert_bool(NombresScript.NOMBRES.has(nombre)).is_true()

func test_tiers_por_tamanio() -> void:
	assert_str(NombresScript.tier_para_tamanio(0.5)).is_equal("Enano")
	assert_str(NombresScript.tier_para_tamanio(1.0)).is_equal("Joven")
	assert_str(NombresScript.tier_para_tamanio(1.9)).is_equal("Joven")
	assert_str(NombresScript.tier_para_tamanio(2.0)).is_equal("Adulto")
	assert_str(NombresScript.tier_para_tamanio(3.9)).is_equal("Adulto")
	assert_str(NombresScript.tier_para_tamanio(4.0)).is_equal("Coloso")

func test_tier_maximo() -> void:
	assert_str(NombresScript.tier_para_tamanio(GameConfig.TAMANIO_MAXIMO)).is_equal("Coloso")
