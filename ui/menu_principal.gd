extends CanvasLayer

signal iniciar
signal skins

const EstiloScript = preload("res://ui/estilo_ui.gd")
const NombreScript = preload("res://core/nombre_jugador.gd")
const CAPA: int = 30

var _campo_nombre: LineEdit

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA

func _ready() -> void:
	visible = false
	var raiz: Control = Control.new()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fondo: TextureRect = EstiloScript.fondo_gradiente()
	raiz.add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var glow: TextureRect = EstiloScript.glow_radial()
	raiz.add_child(glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var adorno: Control = EstiloScript.adorno_bosque()
	raiz.add_child(adorno)
	adorno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro: CenterContainer = CenterContainer.new()
	raiz.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloScript.panel())
	centro.add_child(panel)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	panel.add_child(caja)

	var titulo: Label = Label.new()
	titulo.text = "ESPORA.io"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_titulo(titulo, 76)
	caja.add_child(titulo)

	var subtitulo: Label = Label.new()
	subtitulo.text = "Un hongo. Un claro. Una noche."
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(subtitulo, 18, EstiloScript.TEXTO_TENUE)
	caja.add_child(subtitulo)

	var linea: ColorRect = ColorRect.new()
	linea.color = Color(EstiloScript.ACENTO_TENUE, 0.35)
	linea.custom_minimum_size = Vector2(0.0, 2.0)
	caja.add_child(linea)

	var etiqueta_nombre: Label = Label.new()
	etiqueta_nombre.text = "Tu nombre:"
	etiqueta_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(etiqueta_nombre, 16, EstiloScript.TEXTO_TENUE)
	caja.add_child(etiqueta_nombre)

	_campo_nombre = LineEdit.new()
	_campo_nombre.name = "NombreLobby"
	_campo_nombre.placeholder_text = "2 a 16 caracteres"
	_campo_nombre.max_length = NombreScript.MAXIMO
	_campo_nombre.custom_minimum_size = Vector2(320.0, 42.0)
	_campo_nombre.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_campo_nombre.add_theme_font_override("font", EstiloScript.fuente(400))
	_campo_nombre.add_theme_font_size_override("font_size", 20)
	_campo_nombre.add_theme_color_override("font_color", EstiloScript.TEXTO)
	_campo_nombre.add_theme_color_override("caret_color", EstiloScript.ACENTO)
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		_campo_nombre.text = NombreScript.normalizar(str(gm.get("nombre_jugador")))
	_campo_nombre.text_changed.connect(_on_nombre_cambiado)
	caja.add_child(_campo_nombre)

	var boton_iniciar: Button = _boton("Iniciar partida", "BotonIniciar", false, false)
	caja.add_child(boton_iniciar)
	boton_iniciar.pressed.connect(_on_iniciar)

	var boton_skins: Button = _boton("Skins", "BotonSkins", false, false)
	caja.add_child(boton_skins)
	boton_skins.pressed.connect(_on_skins)

	var salir: Button = _boton("Salir del juego", "BotonSalir", false, true)
	caja.add_child(salir)
	salir.pressed.connect(_on_salir)

func _boton(texto: String, nombre: String, deshabilitado: bool, peligro: bool) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.name = nombre
	boton.custom_minimum_size = Vector2(320.0, 52.0)
	boton.disabled = deshabilitado
	EstiloScript.aplicar_boton(boton, peligro)
	return boton

func _on_iniciar() -> void:
	_guardar_nombre()
	iniciar.emit()

func _on_nombre_cambiado(texto: String) -> void:
	# No forzar el default mientras el usuario esta escribiendo.
	if texto.strip_edges().length() >= NombreScript.MINIMO:
		_aplicar_nombre(texto)

func _guardar_nombre() -> void:
	var final: String = NombreScript.normalizar(_campo_nombre.text if _campo_nombre != null else "")
	if _campo_nombre != null:
		_campo_nombre.text = final
	_aplicar_nombre(final)

func _aplicar_nombre(nombre: String) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.set("nombre_jugador", NombreScript.normalizar(nombre))

func _on_skins() -> void:
	skins.emit()

func _on_salir() -> void:
	get_tree().quit()
