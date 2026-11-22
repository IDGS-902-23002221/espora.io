extends GdUnitTestSuite

const DecoracionScript = preload("res://world/decoracion.gd")

func test_posiciones_dentro_del_anillo() -> void:
	var puntos: Array[Vector3] = DecoracionScript.posiciones(40, 1234, 56.0, 6.0)
	assert_int(puntos.size()).is_equal(40)
	for punto in puntos:
		var radio: float = Vector2(punto.x, punto.z).length()
		assert_float(radio).is_greater_equal(5.99)
		assert_float(radio).is_less_equal(56.01)
		assert_float(punto.y).is_equal(0.0)

func test_posiciones_son_deterministas() -> void:
	var a: Array[Vector3] = DecoracionScript.posiciones(10, 77, 56.0, 6.0)
	var b: Array[Vector3] = DecoracionScript.posiciones(10, 77, 56.0, 6.0)
	assert_vector(a[0]).is_equal(b[0])
	assert_vector(a[9]).is_equal(b[9])
