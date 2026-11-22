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
var _ultima_horda: int = -1
var _mira: Control
var _vidas: Control
var _aviso: Label
var _tiempo_aviso: float = 0.0

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
	_aplicar_estilo()
	_crear_mira()
	_crear_vidas()
	_crear_aviso()
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

func mostrar_aviso(texto: String) -> void:
	if _aviso == null:
		return
	_aviso.text = texto
	_aviso.visible = true
	_tiempo_aviso = 1.6

func _ocultar_puntos_cuadrados() -> void:
	for control in _controles:
		if control != null:
			control.visible = false

func _crear_vidas() -> void:
	_vidas = VidasScript.new() as Control
	_vidas.position = Vector2(16.0, 14.0)
	add_child(_vidas)

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

# Refresca solo cuando cambia el indice; durante la pausa queda la horda terminada.
func _actualizar_horda() -> void:
	if etiqueta_horda == null or _game_manager == null:
		return
	var actual: int = int(_game_manager.get("indice_horda"))
	if actual == _ultima_horda:
		return
	_ultima_horda = actual
	etiqueta_horda.text = "Horda %d/%d" % [actual + 1, Hordas.total()]

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
	if _vidas != null:
		_vidas.call("mostrar", _puntos, _indice_parpadeo)
