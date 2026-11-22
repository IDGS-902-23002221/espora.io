extends CanvasLayer

const EstiloScript = preload("res://ui/estilo_ui.gd")
const MiraScript = preload("res://ui/mira.gd")
const VidasScript = preload("res://ui/vidas.gd")

# Referencia al jugador dueno de los puntos y los 3 controles que los dibujan.
@export var jugador: Node3D
@export var punto_1: ColorRect
@export var punto_2: ColorRect
@export var punto_3: ColorRect
@export var etiqueta_horda: Label
@export var etiqueta_puntaje: Label
@export var etiqueta_intentos: Label

# Colores del indicador de dano (docs/balance-propuesta.md, seccion 4).
const COLOR_LLENO: Color = Color(0.52, 1.0, 0.78, 1.0)
const COLOR_VACIO: Color = Color(0.05, 0.10, 0.07, 1.0)
const COLOR_IMPACTO: Color = Color(0.92, 0.45, 0.36, 1.0)
# Deuda anotada en el ticket: GameConfig esta en "No tocar"; este 0.2 s se
# mueve a GameConfig en el ticket que lo permita.
const DURACION_PARPADEO: float = 0.2

var _puntos: int = GameConfig.IMPACTOS_PARA_ABSORBER
var _controles: Array[ColorRect] = []
var _indice_parpadeo: int = -1
var _tiempo_parpadeo: float = 0.0
# Autoload por ruta y cache de la ultima horda pintada.
var _game_manager: Node
var _texto_horda: String = ""
var _mira: Control
var _vidas: Control
var _max_label: Label
var _aviso: Label
var _tiempo_aviso: float = 0.0
var _vineta: TextureRect
var _tween_vineta: Tween
var _banner: Label
var _flash: ColorRect

func _ready() -> void:
	add_to_group("hud")
	_game_manager = get_node_or_null("/root/GameManager")
	# Si los @export no se asignaron en el editor, se resuelven por nombre.
	if etiqueta_horda == null:
		etiqueta_horda = get_node_or_null("LabelHorda") as Label
	if etiqueta_puntaje == null:
		etiqueta_puntaje = get_node_or_null("LabelPuntaje") as Label
	if etiqueta_intentos == null:
		etiqueta_intentos = get_node_or_null("LabelIntentos") as Label
	_conectar_progreso()
	_actualizar_horda()
	_controles = [punto_1, punto_2, punto_3]
	_ocultar_puntos_cuadrados()
	if jugador != null and jugador.has_method("puntos_actuales"):
		_puntos = int(jugador.call("puntos_actuales"))
		jugador.connect("puntos_cambiados", _on_puntos_cambiados)
		if jugador.has_signal("absorbido"):
			jugador.connect("absorbido", _on_jugador_absorbido)
	_aplicar_estilo()
	_crear_mira()
	_crear_vidas()
	_crear_aviso()
	_crear_vineta()
	_crear_max_label()
	_crear_banner()
	# Pintar siempre, aunque falten referencias: los controles nulos se ignoran.
	_pintar()

func _crear_aviso() -> void:
	_aviso = Label.new()
	_aviso.visible = false
	_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_aviso.offset_left = -300.0
	_aviso.offset_right = 300.0
	_aviso.offset_top = -96.0
	_aviso.offset_bottom = -58.0
	EstiloScript.aplicar_texto(_aviso, 22, EstiloScript.DORADO, 600)
	add_child(_aviso)

func mostrar_aviso(texto: String, duracion: float = 1.6) -> void:
	if _aviso == null:
		return
	_aviso.text = texto
	_aviso.visible = true
	_tiempo_aviso = duracion

func _crear_vineta() -> void:
	var gradiente: Gradient = Gradient.new()
	gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradiente.colors = PackedColorArray([
		Color(0.35, 0.0, 0.0, 0.0),
		Color(0.45, 0.0, 0.0, 0.06),
		Color(0.60, 0.02, 0.02, 0.95),
	])
	var textura: GradientTexture2D = GradientTexture2D.new()
	textura.gradient = gradiente
	textura.width = 512
	textura.height = 512
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)
	_vineta = TextureRect.new()
	_vineta.texture = textura
	_vineta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vineta.stretch_mode = TextureRect.STRETCH_SCALE
	_vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vineta.modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_child(_vineta)
	move_child(_vineta, 0)
	_vineta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _destello_vineta(pico: float, duracion: float) -> void:
	if _vineta == null:
		return
	if _tween_vineta != null and _tween_vineta.is_valid():
		_tween_vineta.kill()
	_vineta.modulate = Color(1.0, 1.0, 1.0, pico)
	_tween_vineta = create_tween()
	_tween_vineta.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_vineta.tween_property(_vineta, "modulate:a", 0.0, duracion)

func _on_jugador_absorbido() -> void:
	# Perder una vida pega mas fuerte que un impacto normal.
	_destello_vineta(0.85, 0.7)

func _crear_banner() -> void:
	_flash = ColorRect.new()
	_flash.color = Color(0.45, 1.0, 0.78, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(_flash, 0)

	_banner = Label.new()
	_banner.name = "BannerHorda"
	_banner.visible = false
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_banner.offset_left = -380.0
	_banner.offset_right = 380.0
	_banner.offset_top = -70.0
	_banner.offset_bottom = 70.0
	EstiloScript.aplicar_titulo(_banner, 30)
	_banner.add_theme_color_override("font_color", EstiloScript.DORADO)
	add_child(_banner)

func mostrar_anuncio_horda(texto: String, duracion: float = 3.5) -> void:
	if _banner == null:
		return
	_banner.text = texto
	_banner.visible = true
	_banner.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if _flash != null:
		_flash.color = Color(0.45, 1.0, 0.78, 0.22)
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tween.tween_interval(maxf(duracion - 0.7, 0.4))
	tween.tween_property(_banner, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func() -> void: _banner.visible = false)
	if _flash != null:
		var tween_flash: Tween = create_tween()
		tween_flash.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_flash.tween_property(_flash, "color:a", 0.0, 0.7)

func _crear_max_label() -> void:
	_max_label = Label.new()
	_max_label.text = "TAMAÑO MÁXIMO"
	_max_label.position = Vector2(16.0, 52.0)
	_max_label.visible = false
	EstiloScript.aplicar_texto(_max_label, 14, EstiloScript.DORADO, 700)
	add_child(_max_label)

func _actualizar_max_label() -> void:
	if _max_label == null or jugador == null:
		return
	var maximo: float = GameConfig.TAMANIO_MAXIMO
	if _game_manager != null and _game_manager.has_method("maximo_actual"):
		maximo = float(_game_manager.call("maximo_actual"))
	_max_label.visible = float(jugador.get("tamanio")) >= maximo

func _ocultar_puntos_cuadrados() -> void:
	for control in _controles:
		if control != null:
			control.visible = false

func _crear_vidas() -> void:
	_vidas = VidasScript.new() as Control
	_vidas.position = Vector2(16.0, 14.0)
	add_child(_vidas)
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		var progreso: Puntaje = gm.get("progreso")
		if progreso != null:
			_vidas.call("mostrar", progreso.intentos, -1)

func _crear_mira() -> void:
	_mira = MiraScript.new() as Control
	_mira.visible = false
	add_child(_mira)

# Proyecta un punto del rumbo real del disparo al espacio de pantalla.
func _actualizar_mira() -> void:
	if _mira == null or jugador == null:
		return
	var camara: Camera3D = jugador.get("camara") as Camera3D
	var origen: Node3D = jugador.get("punto_disparo") as Node3D
	if camara == null or origen == null:
		_mira.visible = false
		return
	var rumbo: Vector3 = -camara.global_basis.z
	rumbo.y = 0.0
	if rumbo.length_squared() < 0.0001:
		_mira.visible = false
		return
	var objetivo: Vector3 = origen.global_position + rumbo.normalized() * 12.0
	if camara.is_position_behind(objetivo):
		_mira.visible = false
		return
	var pantalla: Vector2 = camara.unproject_position(objetivo)
	if not get_viewport().get_visible_rect().has_point(pantalla):
		_mira.visible = false
		return
	_mira.position = pantalla - _mira.size * 0.5
	_mira.visible = true

func _process(delta: float) -> void:
	_actualizar_horda()
	_actualizar_mira()
	_actualizar_aviso(delta)
	_actualizar_max_label()
	if _indice_parpadeo < 0:
		return
	_tiempo_parpadeo -= delta
	if _tiempo_parpadeo > 0.0:
		return
	# Terminado el parpadeo, el punto queda vacio (o lleno si ya regenero).
	_indice_parpadeo = -1
	_pintar()

func _aplicar_estilo() -> void:
	# Texto serif con contorno para leerse sobre el bosque.
	for etiqueta in [etiqueta_horda, etiqueta_puntaje, etiqueta_intentos]:
		if etiqueta != null:
			EstiloScript.aplicar_texto(etiqueta as Label, 20, EstiloScript.TEXTO, 600)

func _actualizar_aviso(delta: float) -> void:
	if _aviso == null or not _aviso.visible:
		return
	_tiempo_aviso -= delta
	if _tiempo_aviso <= 0.0:
		_aviso.visible = false

func _on_puntos_cambiados(restantes: int) -> void:
	if restantes < _puntos:
		# El impacto vacia el punto con indice "restantes" (0-based).
		_indice_parpadeo = restantes
		_tiempo_parpadeo = DURACION_PARPADEO
		_destello_vineta(0.5, 0.35)
	elif restantes > _puntos:
		# Al regenerar no parpadea.
		_indice_parpadeo = -1
	_puntos = restantes
	_pintar()

func _conectar_progreso() -> void:
	if _game_manager == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso == null:
		return
	progreso.puntaje_cambiado.connect(_on_puntaje_cambiado)
	progreso.intentos_cambiados.connect(_on_intentos_cambiados)
	_on_puntaje_cambiado(progreso.puntos)
	_on_intentos_cambiados(progreso.intentos)

func _on_puntaje_cambiado(total: int) -> void:
	if etiqueta_puntaje != null:
		etiqueta_puntaje.text = "Puntaje: %d" % total

func _on_intentos_cambiados(restantes: int) -> void:
	if etiqueta_intentos != null:
		etiqueta_intentos.text = "Intentos: %d" % restantes
	if _vidas != null:
		_vidas.call("mostrar", restantes, -1)

# Refresca solo cuando cambia el indice; durante la pausa queda la horda terminada.
func _actualizar_horda() -> void:
	if etiqueta_horda == null or _game_manager == null:
		return
	var hordas: Hordas = _game_manager.get("hordas")
	if hordas == null:
		return
	var texto: String = ""
	if hordas.terminada:
		texto = "Amanecer"
	elif hordas.en_pausa:
		texto = "Siguiente horda: %s" % _formato_tiempo(hordas.tiempo_restante)
	else:
		texto = "Horda %d/%d  %s" % [
			hordas.indice + 1, Hordas.total(), _formato_tiempo(hordas.tiempo_restante)
		]
	if texto == _texto_horda:
		return
	_texto_horda = texto
	etiqueta_horda.text = texto

static func _formato_tiempo(segundos: float) -> String:
	var total: int = maxi(ceili(segundos), 0)
	return "%02d:%02d" % [total / 60, total % 60]

func _pintar() -> void:
	for i in _controles.size():
		var control: ColorRect = _controles[i]
		if control == null:
			continue
		if i == _indice_parpadeo:
			control.color = COLOR_IMPACTO
		elif i < _puntos:
			control.color = COLOR_LLENO
		else:
			control.color = COLOR_VACIO
