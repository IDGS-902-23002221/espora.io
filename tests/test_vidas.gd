extends GdUnitTestSuite

const VidasScript = preload("res://ui/vidas.gd")

func test_vida_arranca_llena() -> void:
	var vidas: Control = VidasScript.new() as Control
	add_child(vidas)
	assert_int(vidas.call("puntos_actuales")).is_equal(6)
	assert_vector(vidas.custom_minimum_size).is_equal(Vector2(120.0, 36.0))
	vidas.free()

func test_vida_se_actualiza_y_respeta_el_maximo() -> void:
	var vidas: Control = VidasScript.new() as Control
	add_child(vidas)
	vidas.call("mostrar", 5, -1)
	assert_int(vidas.call("puntos_actuales")).is_equal(5)
	vidas.call("mostrar", 9, -1)
	assert_int(vidas.call("puntos_actuales")).is_equal(6)
	vidas.free()
