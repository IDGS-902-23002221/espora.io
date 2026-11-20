extends GdUnitTestSuite

const MenuPrincipalScript = preload("res://ui/menu_principal.gd")
const MenuSkinsScript = preload("res://ui/menu_skins.gd")
const MenuPausaScript = preload("res://ui/menu_pausa.gd")
const PantallaCargaScript = preload("res://ui/pantalla_carga.gd")

func test_menu_principal_emite_iniciar() -> void:
	var menu: CanvasLayer = MenuPrincipalScript.new() as CanvasLayer
	add_child(menu)
	var boton: Button = menu.find_child("BotonIniciar", true, false) as Button
	assert_object(boton).is_not_null()
	var veces: Array[int] = [0]
	menu.connect("iniciar", func() -> void: veces[0] += 1)
	boton.pressed.emit()
	assert_int(veces[0]).is_equal(1)
	menu.free()

func test_menu_principal_emite_skins() -> void:
	var menu: CanvasLayer = MenuPrincipalScript.new() as CanvasLayer
	add_child(menu)
	var boton: Button = menu.find_child("BotonSkins", true, false) as Button
	assert_object(boton).is_not_null()
	var veces: Array[int] = [0]
	menu.connect("skins", func() -> void: veces[0] += 1)
	boton.pressed.emit()
	assert_int(veces[0]).is_equal(1)
	menu.free()

func test_menu_pausa_emite_reanudar_y_abandonar() -> void:
	var menu: CanvasLayer = MenuPausaScript.new() as CanvasLayer
	add_child(menu)
	var reanudar: Button = menu.find_child("BotonReanudar", true, false) as Button
	var abandonar: Button = menu.find_child("BotonAbandonar", true, false) as Button
	assert_object(reanudar).is_not_null()
	assert_object(abandonar).is_not_null()
	var cuenta: Array[int] = [0, 0]
	menu.connect("reanudar", func() -> void: cuenta[0] += 1)
	menu.connect("abandonar", func() -> void: cuenta[1] += 1)
	reanudar.pressed.emit()
	abandonar.pressed.emit()
	assert_int(cuenta[0]).is_equal(1)
	assert_int(cuenta[1]).is_equal(1)
	menu.free()

func test_selector_carrusel_emite_skin_y_volver() -> void:
	var menu: CanvasLayer = MenuSkinsScript.new() as CanvasLayer
	add_child(menu)
	var anterior: Button = menu.find_child("BotonAnterior", true, false) as Button
	var siguiente: Button = menu.find_child("BotonSiguiente", true, false) as Button
	var boton_volver: Button = menu.find_child("BotonVolver", true, false) as Button
	var etiqueta: Label = menu.find_child("EtiquetaSkin", true, false) as Label
	assert_object(anterior).is_not_null()
	assert_object(siguiente).is_not_null()
	assert_object(boton_volver).is_not_null()
	assert_object(etiqueta).is_not_null()
	var elegida: Array[String] = [""]
	var vueltas: Array[int] = [0]
	menu.connect("seleccionada", func(nombre: String) -> void: elegida[0] = nombre)
	menu.connect("volver", func() -> void: vueltas[0] += 1)
	menu.call("marcar_actual", "clasico")
	assert_str(etiqueta.text).is_equal("Clásico")
	siguiente.pressed.emit()
	assert_str(elegida[0]).is_equal("luminaria")
	assert_str(etiqueta.text).is_equal("Luminaria")
	siguiente.pressed.emit()
	assert_str(elegida[0]).is_equal("rey")
	# Al pasar del ultimo, el carrusel vuelve al primero.
	siguiente.pressed.emit()
	assert_str(elegida[0]).is_equal("clasico")
	anterior.pressed.emit()
	assert_str(elegida[0]).is_equal("rey")
	boton_volver.pressed.emit()
	assert_int(vueltas[0]).is_equal(1)
	menu.free()

func test_carga_emite_terminada() -> void:
	var carga: CanvasLayer = PantallaCargaScript.new() as CanvasLayer
	add_child(carga)
	var emitida: Array[int] = [0]
	carga.connect("terminada", func() -> void: emitida[0] += 1)
	carga.call("iniciar", 0.05)
	await get_tree().create_timer(0.2, true).timeout
	assert_int(emitida[0]).is_equal(1)
	carga.free()
