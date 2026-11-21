extends CanvasLayer

signal terminada

const EstiloScript = preload("res://ui/estilo_ui.gd")
const CAPA: int = 50
# Segundos por beat antes de pasar al siguiente.
const DURACION_BEAT: float = 4.2

var _titulo: Label
var _subtitulo: Label
var _texto: Label
var _boton: Button
var _particulas: CPUParticles2D
var _tinte: ColorRect
var _tween: Tween
var _escenas: Array = []
var _indice: int = 0
var _tiempo: float = 0.0
var _activa: bool = false

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

	_particulas = _crear_particulas()
	raiz.add_child(_particulas)

	_tinte = ColorRect.new()
	_tinte.name = "Tinte"
	_tinte.color = Color(0.0, 0.0, 0.0, 0.0)
	_tinte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_tinte)
	_tinte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro: CenterContainer = CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override("separation", 12)
	centro.add_child(caja)

	_titulo = Label.new()
	_titulo.name = "TituloCinematica"
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_titulo(_titulo, 44)
	caja.add_child(_titulo)

	_subtitulo = Label.new()
	_subtitulo.name = "SubtituloCinematica"
	_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitulo.add_theme_font_override("font", EstiloScript.fuente(600))
	_subtitulo.add_theme_font_size_override("font_size", 22)
	_subtitulo.add_theme_color_override("font_color", Color(0.45, 1.0, 1.0))
	caja.add_child(_subtitulo)

	_texto = Label.new()
	_texto.name = "TextoCinematica"
	_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.custom_minimum_size = Vector2(780.0, 0.0)
	_texto.add_theme_font_override("font", EstiloScript.fuente(400))
	_texto.add_theme_font_size_override("font_size", 20)
	_texto.add_theme_color_override("font_color", Color(0.82, 0.92, 1.0))
	caja.add_child(_texto)

	_boton = Button.new()
	_boton.name = "BotonSaltar"
	_boton.custom_minimum_size = Vector2(220.0, 46.0)
	EstiloScript.aplicar_boton(_boton, false)
	_boton.pressed.connect(_on_boton)
	raiz.add_child(_boton)
	_boton.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_boton.offset_left = -260.0
	_boton.offset_top = -86.0
	_boton.offset_right = -40.0
	_boton.offset_bottom = -40.0

func mostrar(escenas: Array) -> void:
	if escenas.is_empty():
		return
	_escenas = escenas
	_indice = 0
	_tiempo = 0.0
	_activa = true
	visible = true
	if _particulas != null:
		_particulas.emitting = true
	_mostrar_beat()

func _mostrar_beat() -> void:
	var datos: Dictionary = _escenas[_indice]
	_titulo.text = str(datos["titulo"])
	_subtitulo.text = str(datos["subtitulo"])
	_texto.text = str(datos["texto"])
	_boton.text = str(datos["boton"])
	_tiempo = 0.0
	_aplicar_tinte(datos)
	_animar_entrada()

func _aplicar_tinte(datos: Dictionary) -> void:
	if _tinte != null:
		_tinte.color = datos.get("tinte", Color(0.0, 0.0, 0.0, 0.0))
	if _particulas != null:
		_particulas.color = datos.get("particulas_color", Color(0.35, 1.0, 1.0, 0.35))

func _animar_entrada() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var controles: Array[Control] = [_titulo, _subtitulo, _texto, _boton]
	for control in controles:
		var modulacion: Color = control.modulate
		modulacion.a = 0.0
		control.modulate = modulacion
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	var retraso: float = 0.0
	for control in controles:
		_tween.tween_property(control, "modulate:a", 1.0, 0.5).set_delay(retraso)
		retraso += 0.12

func _process(delta: float) -> void:
	if not _activa:
		return
	_tiempo += delta
	if _tiempo < DURACION_BEAT:
		return
	_indice += 1
	if _indice >= _escenas.size():
		_terminar()
		return
	_mostrar_beat()

func _terminar() -> void:
	_activa = false
	visible = false
	if _particulas != null:
		_particulas.emitting = false
	terminada.emit()

func _on_boton() -> void:
	_terminar()

func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("pausa"):
		_terminar()

func _crear_particulas() -> CPUParticles2D:
	var particulas: CPUParticles2D = CPUParticles2D.new()
	particulas.amount = 45
	particulas.lifetime = 10.0
	particulas.preprocess = 10.0
	particulas.emission_shape = 3 # EMISSION_SHAPE_RECTANGLE
	particulas.emission_rect_extents = Vector2(620.0, 360.0)
	particulas.direction = Vector2(0.0, -1.0)
	particulas.spread = 180.0
	particulas.gravity = Vector2.ZERO
	particulas.initial_velocity_min = 6.0
	particulas.initial_velocity_max = 20.0
	particulas.scale_amount_min = 0.04
	particulas.scale_amount_max = 0.12
	particulas.color = Color(0.35, 1.0, 1.0, 0.35)
	particulas.position = Vector2(576.0, 324.0)
	particulas.texture = _textura_particula()
	particulas.emitting = false
	return particulas

func _textura_particula() -> GradientTexture2D:
	var gradiente: Gradient = Gradient.new()
	gradiente.colors = PackedColorArray([Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0)])
	gradiente.offsets = PackedFloat32Array([0.0, 1.0])
	var textura: GradientTexture2D = GradientTexture2D.new()
	textura.gradient = gradiente
	textura.width = 16
	textura.height = 16
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)
	return textura
