extends GdUnitTestSuite

const JugadorScript = preload("res://entities/player/player.gd")
const EscudoScript = preload("res://entities/pickup/escudo.gd")

class CuerpoFalso extends Node3D:
	var activado: bool = false

	func activar_escudo() -> void:
		activado = true

func test_bloquea_impacto_solo_si_esta_activo() -> void:
	assert_bool(JugadorScript.bloquea_impacto(0.0)).is_false()
	assert_bool(JugadorScript.bloquea_impacto(0.01)).is_true()

func test_pickup_activa_el_escudo() -> void:
	var escudo: Area3D = EscudoScript.new() as Area3D
	add_child(escudo)
	var cuerpo: CuerpoFalso = CuerpoFalso.new()
	escudo.call("_on_body_entered", cuerpo)
	assert_bool(cuerpo.activado).is_true()
	assert_bool(escudo.is_queued_for_deletion()).is_true()
	cuerpo.free()
