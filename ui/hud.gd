extends CanvasLayer

# Referencia al jugador dueno de los puntos y los 3 controles que los dibujan.
@export var jugador: Node3D
@export var punto_1: ColorRect
@export var punto_2: ColorRect
@export var punto_3: ColorRect
@export var etiqueta_horda: Label
@export var etiqueta_puntaje: Label
@export var etiqueta_intentos: Label

# Colores del indicador de dano (docs/balance-propuesta.md, seccion 4).
const COLOR_LLENO: Color = Color(0.0, 1.0, 1.0, 1.0)
const COLOR_VACIO: Color = Color(0.13, 0.13, 0.13, 1.0)
const COLOR_IMPACTO: Color = Color(0.9, 0.1, 0.1, 1.0)
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

func _ready() -> void:
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
	if jugador != null and jugador.has_method("puntos_actuales"):
		_puntos = int(jugador.call("puntos_actuales"))
		jugador.connect("puntos_cambiados", _on_puntos_cambiados)
	# Pintar siempre, aunque falten referencias: los controles nulos se ignoran.
	_pintar()

func _process(delta: float) -> void:
	_actualizar_horda()
	if _indice_parpadeo < 0:
		return
	_tiempo_parpadeo -= delta
	if _tiempo_parpadeo > 0.0:
		return
	# Terminado el parpadeo, el punto queda vacio (o lleno si ya regenero).
	_indice_parpadeo = -1
	_pintar()

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
