extends GdUnitTestSuite

func test_textos_victoria() -> void:
	var datos: Dictionary = ResultadoPartida.textos(true, 360, 2, 1.5, 470.0)
	assert_str(datos["titulo"]).is_equal("¡Amanece!")
	assert_str(datos["subtitulo"]).is_equal("Tu micelio dominó el claro.")
	var lineas: Array = datos["lineas"]
	assert_str(lineas[0]).is_equal("Puntaje: 360")
	assert_str(lineas[1]).is_equal("NPC absorbidos: 2")
	assert_str(lineas[2]).is_equal("Tamaño máximo: 1.5")
	assert_str(lineas[3]).is_equal("Tiempo: 07:50")
	assert_str(datos["boton"]).is_equal("Jugar de nuevo")

func test_textos_derrota() -> void:
	var datos: Dictionary = ResultadoPartida.textos(false, 0, 0, 1.0, 0.0)
	assert_str(datos["titulo"]).is_equal("Te absorbieron")
	assert_str(datos["subtitulo"]).is_equal("Tu micelio se disolvió antes del amanecer.")
	var lineas: Array = datos["lineas"]
	assert_str(lineas[0]).is_equal("Puntaje: 0")
	assert_str(lineas[3]).is_equal("Tiempo: 00:00")

func test_tamanio_con_un_decimal() -> void:
	var datos: Dictionary = ResultadoPartida.textos(true, 0, 0, 2.0, 0.0)
	var lineas: Array = datos["lineas"]
	assert_str(lineas[2]).is_equal("Tamaño máximo: 2.0")

func test_tiempo_de_una_partida_completa() -> void:
	var datos: Dictionary = ResultadoPartida.textos(true, 0, 0, 1.0, 470.0)
	var lineas: Array = datos["lineas"]
	assert_str(lineas[3]).is_equal("Tiempo: 07:50")
