extends CanvasLayer

signal reanudar
signal abandonar

const EstiloScript = preload("res://ui/estilo_ui.gd")
const CAPA: int = 35

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
	caja.add_theme_constant_override("separation", 14)
	panel.add_child(caja)

	var titulo: Label = Label.new()
	titulo.text = "Pausa"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_titulo(titulo, 56)
	caja.add_child(titulo)

	var boton_reanudar: Button = _boton("Reanudar", "BotonReanudar")
	caja.add_child(boton_reanudar)
	boton_reanudar.pressed.connect(_on_reanudar)

	var boton_abandonar: Button = _boton("Abandonar partida", "BotonAbandonar")
	caja.add_child(boton_abandonar)
	boton_abandonar.pressed.connect(_on_abandonar)

func _boton(texto: String, nombre: String) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.name = nombre
	boton.custom_minimum_size = Vector2(300.0, 52.0)
	EstiloScript.aplicar_boton(boton, nombre == "BotonAbandonar")
	return boton

func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("pausa"):
		reanudar.emit()

func _on_reanudar() -> void:
	reanudar.emit()

func _on_abandonar() -> void:
	abandonar.emit()
