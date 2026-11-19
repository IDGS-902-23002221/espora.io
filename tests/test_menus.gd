extends GdUnitTestSuite

const MenuPrincipalScript = preload("res://ui/menu_principal.gd")
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

func test_carga_emite_terminada() -> void:
	var carga: CanvasLayer = PantallaCargaScript.new() as CanvasLayer
	add_child(carga)
	var emitida: Array[int] = [0]
	carga.connect("terminada", func() -> void: emitida[0] += 1)
	carga.call("iniciar", 0.05)
	await get_tree().create_timer(0.2, true).timeout
	assert_int(emitida[0]).is_equal(1)
	carga.free()
