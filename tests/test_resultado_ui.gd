extends GdUnitTestSuite

const EscenaResultado = preload("res://ui/pantalla_resultado.tscn")
const PuntajeScript = preload("res://core/puntaje.gd")

func test_resultado_usa_panel_y_boton_lobby() -> void:
	var pantalla: CanvasLayer = EscenaResultado.instantiate() as CanvasLayer
	add_child(pantalla)
	pantalla.call("mostrar", false, PuntajeScript.new())
	assert_object(pantalla.find_child("PanelResultado", true, false)).is_not_null()
	var boton: Button = pantalla.find_child("ButtonReiniciar", true, false) as Button
	assert_object(boton).is_not_null()
	assert_str(boton.text).is_equal("Jugar de nuevo")
	var lobby: Button = pantalla.find_child("BotonLobby", true, false) as Button
	assert_object(lobby).is_not_null()
	assert_str(lobby.text).is_equal("Volver al lobby")
	var nombre: LineEdit = pantalla.find_child("NombreJugador", true, false) as LineEdit
	assert_object(nombre).is_not_null()
	assert_int(nombre.max_length).is_equal(16)
	pantalla.free()
