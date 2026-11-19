extends GdUnitTestSuite

const EscenaNutriente = preload("res://entities/nutrient/nutrient.tscn")

class CuerpoFalso extends Node3D:
	var multiplicador: float = 0.0

	func consumir_nutriente(m: float) -> void:
		multiplicador = m

func _crear_nutriente() -> Area3D:
	var nutriente: Area3D = EscenaNutriente.instantiate() as Area3D
	add_child(nutriente)
	return nutriente

func test_pasa_el_multiplicador_dorado() -> void:
	var nutriente: Area3D = _crear_nutriente()
	nutriente.set("multiplicador_crecimiento", GameConfig.MULT_NUTRIENTE_DORADO)
	var cuerpo: CuerpoFalso = CuerpoFalso.new()
	nutriente.call("_on_body_entered", cuerpo)
	assert_float(cuerpo.multiplicador).is_equal_approx(GameConfig.MULT_NUTRIENTE_DORADO, 0.0001)
	assert_bool(nutriente.is_queued_for_deletion()).is_true()
	cuerpo.free()

func test_multiplicador_por_defecto_es_uno() -> void:
	var nutriente: Area3D = _crear_nutriente()
	var cuerpo: CuerpoFalso = CuerpoFalso.new()
	nutriente.call("_on_body_entered", cuerpo)
	assert_float(cuerpo.multiplicador).is_equal_approx(1.0, 0.0001)
	assert_bool(nutriente.is_queued_for_deletion()).is_true()
	cuerpo.free()
