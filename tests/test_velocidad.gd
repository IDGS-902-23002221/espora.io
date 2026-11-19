extends GdUnitTestSuite

const JugadorScript = preload("res://entities/player/player.gd")
const VelocidadScript = preload("res://entities/pickup/velocidad.gd")

class CuerpoFalso extends Node3D:
	var activado: bool = false

	func activar_velocidad() -> void:
		activado = true

func test_multiplicador_solo_si_esta_activo() -> void:
	assert_float(JugadorScript.multiplicador_velocidad(0.0)).is_equal_approx(1.0, 0.0001)
	assert_float(JugadorScript.multiplicador_velocidad(0.01)).is_equal_approx(GameConfig.MULT_VELOCIDAD_ESPORA_VELOZ, 0.0001)

func test_pickup_activa_la_velocidad() -> void:
	var velocidad: Area3D = VelocidadScript.new() as Area3D
	add_child(velocidad)
	var cuerpo: CuerpoFalso = CuerpoFalso.new()
	velocidad.call("_on_body_entered", cuerpo)
	assert_bool(cuerpo.activado).is_true()
	assert_bool(velocidad.is_queued_for_deletion()).is_true()
	cuerpo.free()
