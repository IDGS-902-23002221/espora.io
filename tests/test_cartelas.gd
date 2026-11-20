extends GdUnitTestSuite

const CartelasScript = preload("res://core/cartelas.gd")
const CinematicaScript = preload("res://ui/cinematica.gd")

func test_apertura_historia() -> void:
	var escenas: Array = CartelasScript.apertura()
	assert_int(escenas.size()).is_equal(4)
	assert_str(str(escenas[0]["texto"])).contains("humanos")
	assert_str(str(escenas[3]["texto"])).contains("Cuando el sol se oculta")
	assert_str(str(escenas[0]["boton"])).is_equal("Saltar")

func test_acto_i_dos_escenas() -> void:
	var escenas: Array = CartelasScript.acto_i()
	assert_int(escenas.size()).is_equal(2)
	assert_str(str(escenas[0]["titulo"])).contains("ACTO I")

func test_acto_iv_victoria_y_derrota() -> void:
	var victoria: Array = CartelasScript.acto_iv(true)
	var derrota: Array = CartelasScript.acto_iv(false)
	assert_str(str(victoria[0]["titulo"])).contains("AMANECER")
	assert_str(str(derrota[0]["titulo"])).contains("OSCURIDAD")
	assert_str(str(victoria[1]["texto"])).contains("Dominaste")
	assert_str(str(derrota[1]["texto"])).contains("espera")
	assert_bool(victoria[0].has("tinte")).is_true()
	assert_bool(derrota[0].has("tinte")).is_true()

func test_cinematica_emite_terminada() -> void:
	var cinematica: CanvasLayer = CinematicaScript.new() as CanvasLayer
	add_child(cinematica)
	var veces: Array[int] = [0]
	cinematica.connect("terminada", func() -> void: veces[0] += 1)
	cinematica.call("mostrar", CartelasScript.acto_i())
	var boton: Button = cinematica.find_child("BotonSaltar", true, false) as Button
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Continuar")
	boton.pressed.emit()
	assert_int(veces[0]).is_equal(1)
	cinematica.free()
