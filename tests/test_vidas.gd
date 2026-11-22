extends GdUnitTestSuite

const VidasScript = preload("res://ui/vidas.gd")

func test_vidas_arrancan_en_tres() -> void:
	var vidas: Control = VidasScript.new() as Control
	add_child(vidas)
	assert_int(vidas.call("vidas_actuales")).is_equal(3)
	assert_vector(vidas.custom_minimum_size).is_equal(Vector2(120.0, 36.0))
	vidas.free()

func test_vidas_se_actualizan() -> void:
	var vidas: Control = VidasScript.new() as Control
	add_child(vidas)
	vidas.call("mostrar", 1, -1)
	assert_int(vidas.call("vidas_actuales")).is_equal(1)
	vidas.call("mostrar", 4, -1)
	assert_int(vidas.call("vidas_actuales")).is_equal(3)
	vidas.free()
