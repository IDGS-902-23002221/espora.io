extends CanvasLayer

signal iniciar
signal skins

const EstiloScript = preload("res://ui/estilo_ui.gd")
const CAPA: int = 30

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
	subtitulo.add_theme_font_override("font", EstiloScript.fuente(400))
	subtitulo.add_theme_font_size_override("font_size", 18)
	subtitulo.add_theme_color_override("font_color", Color(0.62, 0.78, 0.92))
	caja.add_child(subtitulo)

	var linea: ColorRect = ColorRect.new()
	linea.color = Color(0.2, 0.8, 0.9, 0.35)
	linea.custom_minimum_size = Vector2(0.0, 2.0)
	caja.add_child(linea)

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
	iniciar.emit()

func _on_skins() -> void:
	skins.emit()

func _on_salir() -> void:
	get_tree().quit()
