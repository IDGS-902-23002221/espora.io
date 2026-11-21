extends GdUnitTestSuite

const EstiloScript = preload("res://ui/estilo_ui.gd")

func test_paleta_de_bosque() -> void:
	# El acento y el fondo deben tirar a verde, no a azul/violeta.
	assert_bool(EstiloScript.ACENTO.g > EstiloScript.ACENTO.r).is_true()
	assert_bool(EstiloScript.ACENTO.g > EstiloScript.ACENTO.b).is_true()
	assert_bool(EstiloScript.FONDO_BOSQUE.g > EstiloScript.FONDO_BOSQUE.b).is_true()

func test_panel_y_borde_verdes() -> void:
	var panel: StyleBoxFlat = EstiloScript.panel()
	assert_bool(panel.bg_color.g > panel.bg_color.r).is_true()
	assert_bool(panel.border_color.g > panel.border_color.b).is_true()

func test_adorno_bosque_ignora_mouse() -> void:
	var adorno: Control = EstiloScript.adorno_bosque()
	add_child(adorno)
	assert_object(adorno).is_not_null()
	assert_int(adorno.mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	adorno.free()
