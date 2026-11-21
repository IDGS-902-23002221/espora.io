extends CanvasLayer

signal terminada

const EstiloScript = preload("res://ui/estilo_ui.gd")
const CAPA: int = 40

var _barra: ProgressBar
var _tween: Tween

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
	titulo.text = "Cargando..."
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_titulo(titulo, 40)
	caja.add_child(titulo)

	var subtitulo: Label = Label.new()
	subtitulo.text = "Preparando el claro..."
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(subtitulo, 18, EstiloScript.TEXTO_TENUE)
	caja.add_child(subtitulo)

	_barra = ProgressBar.new()
	_barra.custom_minimum_size = Vector2(360.0, 16.0)
	_barra.show_percentage = false
	_barra.value = 0.0
	_barra.add_theme_stylebox_override("background", EstiloScript.barra(Color(0.03, 0.08, 0.06, 1.0)))
	_barra.add_theme_stylebox_override("fill", EstiloScript.barra(EstiloScript.ACENTO))
	caja.add_child(_barra)

func iniciar(duracion: float = 0.8) -> void:
	visible = true
	_barra.value = 0.0
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(_barra, "value", 100.0, duracion)
	_tween.tween_callback(_terminar)

func _terminar() -> void:
	visible = false
	terminada.emit()
