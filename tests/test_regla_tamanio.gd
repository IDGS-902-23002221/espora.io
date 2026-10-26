extends GdUnitTestSuite

const NEUTRAL: int = ReglaTamanio.EstadoTamanio.NEUTRAL
const PERSEGUIR: int = ReglaTamanio.EstadoTamanio.PERSEGUIR
const HUIR: int = ReglaTamanio.EstadoTamanio.HUIR

func test_entrada_exacta_a_perseguir() -> void:
	assert_int(ReglaTamanio.siguiente_estado(NEUTRAL, 1.10, 1.0)).is_equal(PERSEGUIR)

func test_entrada_exacta_a_huir() -> void:
	assert_int(ReglaTamanio.siguiente_estado(NEUTRAL, 0.90, 1.0)).is_equal(HUIR)

func test_zona_neutral() -> void:
	for proporcion in [0.91, 0.95, 1.0, 1.05, 1.09]:
		assert_int(ReglaTamanio.siguiente_estado(NEUTRAL, proporcion, 2.0)).is_equal(NEUTRAL)

func test_histeresis_perseguir() -> void:
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 1.07, 2.0)).is_equal(PERSEGUIR)
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 1.05, 2.0)).is_equal(PERSEGUIR)
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 1.049, 2.0)).is_equal(NEUTRAL)

func test_histeresis_huir() -> void:
	assert_int(ReglaTamanio.siguiente_estado(HUIR, 0.93, 2.0)).is_equal(HUIR)
	assert_int(ReglaTamanio.siguiente_estado(HUIR, 0.95, 2.0)).is_equal(HUIR)
	assert_int(ReglaTamanio.siguiente_estado(HUIR, 0.951, 2.0)).is_equal(NEUTRAL)

func test_perseguir_a_huir_directo() -> void:
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 0.90, 2.0)).is_equal(HUIR)

func test_huir_a_perseguir_directo() -> void:
	assert_int(ReglaTamanio.siguiente_estado(HUIR, 1.10, 2.0)).is_equal(PERSEGUIR)

func test_tiempo_minimo_conserva_el_estado() -> void:
	assert_int(ReglaTamanio.siguiente_estado(NEUTRAL, 1.20, 0.99)).is_equal(NEUTRAL)
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 0.80, 0.99)).is_equal(PERSEGUIR)

func test_tiempo_minimo_permite_cambiar() -> void:
	assert_int(ReglaTamanio.siguiente_estado(NEUTRAL, 1.20, 1.0)).is_equal(PERSEGUIR)
	assert_int(ReglaTamanio.siguiente_estado(PERSEGUIR, 0.80, 1.0)).is_equal(HUIR)

func test_frontera_no_oscila() -> void:
	var estado: int = PERSEGUIR
	var proporciones: Array[float] = [1.06, 1.04, 1.06, 1.04, 1.09, 1.10]
	var esperados: Array[int] = [PERSEGUIR, NEUTRAL, NEUTRAL, NEUTRAL, NEUTRAL, PERSEGUIR]
	for i in proporciones.size():
		estado = ReglaTamanio.siguiente_estado(estado, proporciones[i], 1.0)
		assert_int(estado).is_equal(esperados[i])

func test_proporcion_con_objetivo_invalido() -> void:
	assert_float(ReglaTamanio.proporcion(1.0, 0.0)).is_equal(1.0)
	assert_float(ReglaTamanio.proporcion(1.0, -2.0)).is_equal(1.0)
	assert_float(ReglaTamanio.proporcion(2.0, 1.0)).is_equal(2.0)
