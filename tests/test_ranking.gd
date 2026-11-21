extends GdUnitTestSuite

const RankingScript = preload("res://core/ranking.gd")
const RankingVivoScript = preload("res://ui/ranking_vivo.gd")

func test_puntos_por_tamanio() -> void:
	assert_int(RankingScript.puntos_para(0.0)).is_equal(0)
	assert_int(RankingScript.puntos_para(1.0)).is_equal(100)
	assert_int(RankingScript.puntos_para(3.45)).is_equal(345)
	assert_int(RankingScript.puntos_para(-2.0)).is_equal(0)

func test_ordenar_por_tamanio_y_cortar() -> void:
	var entradas: Array = [
		RankingScript.entrada("Chico", 1.0),
		RankingScript.entrada("Grande", 4.0),
		RankingScript.entrada("Medio", 2.5),
	]
	var orden: Array = RankingScript.ordenar(entradas, 2)
	assert_int(orden.size()).is_equal(2)
	assert_str(orden[0]["nombre"]).is_equal("Grande")
	assert_str(orden[1]["nombre"]).is_equal("Medio")

func test_jugador_marcado_y_empate_alfabetico() -> void:
	var a: Dictionary = RankingScript.entrada("Beta", 2.0)
	var b: Dictionary = RankingScript.entrada("Alfa", 2.0)
	var jugador: Dictionary = RankingScript.entrada("Tú", 2.0, true)
	var orden: Array = RankingScript.ordenar([a, b, jugador], 3)
	assert_str(orden[0]["nombre"]).is_equal("Alfa")
	assert_str(orden[1]["nombre"]).is_equal("Beta")
	assert_bool(orden[2]["es_jugador"]).is_true()

func test_ui_dibuja_filas_y_jugador() -> void:
	var panel: CanvasLayer = RankingVivoScript.new() as CanvasLayer
	add_child(panel)
	var entradas: Array = [
		RankingScript.entrada("Grande", 4.0),
		RankingScript.entrada("Tú", 2.0, true),
	]
	panel.call("mostrar_entradas", RankingScript.ordenar(entradas, 5))
	var filas: Node = panel.find_child("FilasRanking", true, false)
	assert_object(filas).is_not_null()
	assert_int(filas.get_child_count()).is_equal(2)
	var fila_2: Node = panel.find_child("FilaRanking2", true, false)
	assert_object(fila_2).is_not_null()
	var etiquetas: Array = fila_2.get_children()
	assert_str((etiquetas[1] as Label).text).is_equal("Tú")
	panel.free()
