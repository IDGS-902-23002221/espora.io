extends GdUnitTestSuite

const FormasScript = preload("res://core/formas.gd")

func test_hoja_tiene_una_superficie() -> void:
	var malla: ArrayMesh = FormasScript.hoja_malla()
	assert_object(malla).is_not_null()
	assert_int(malla.get_surface_count()).is_equal(1)

func test_hoja_tiene_volumen_visible() -> void:
	var malla: ArrayMesh = FormasScript.hoja_malla()
	var caja: AABB = malla.get_aabb()
	assert_float(caja.size.y).is_greater(0.5)
	assert_float(caja.size.x).is_greater(0.3)
