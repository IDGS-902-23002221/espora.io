extends GdUnitTestSuite

const NombreScript = preload("res://core/nombre_jugador.gd")

func test_nombre_minimo_dos_caracteres() -> void:
	assert_str(NombreScript.normalizar("")).is_equal(NombreScript.DEFECTO)
	assert_str(NombreScript.normalizar("a")).is_equal(NombreScript.DEFECTO)
	assert_str(NombreScript.normalizar("ab")).is_equal("ab")

func test_nombre_maximo_dieciseis() -> void:
	assert_int(NombreScript.normalizar("abcdefghijklmnopqrstuvwxyz").length()).is_equal(16)
