extends SpringArm3D

# Limite de pixeles por evento: evita que un pico del mouse gire la camara de golpe.
const DELTA_MAXIMO_MOUSE: float = 150.0
# Margen del brazo para que no se pegue a la colision al acercarse al suelo.
const MARGEN_SPRING_ARM: float = 0.2
const LONGITUD_BASE: float = 8.0
const ALTURA_PIVOTE_MIN: float = 1.6
const ALTURA_PIVOTE_MAX: float = 6.5
# La camara nunca baja de esta altura: evita mirar bajo el piso.
const ALTURA_SUELO: float = 0.25

@export var sensibilidad: float = 0.0025
@export var limite_pitch_min: float = -60.0
@export var limite_pitch_max: float = 60.0
@export var offset_hombro: float = 1.6

# Tras recuperar foco, el primer movimiento relativo puede venir enorme.
var _ignorar_siguiente_movimiento: bool = false
var _tamanio: float = 1.0
var _primera_persona: bool = false
var _visual: Node3D
var _camara: Camera3D

func _ready() -> void:
	margin = MARGEN_SPRING_ARM
	_visual = get_parent().get_node_or_null("Visual") as Node3D
	_camara = get_node_or_null("Camera3D") as Camera3D
	configurar_tamanio(1.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_ignorar_siguiente_movimiento = true

func _unhandled_input(evento: InputEvent) -> void:
	if evento is InputEventKey:
		var tecla: InputEventKey = evento
		if tecla.pressed and not tecla.echo and tecla.physical_keycode == KEY_V:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				alternar_primera_persona()
				get_viewport().set_input_as_handled()
		return
	if evento is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var movimiento: InputEventMouseMotion = evento
		if _ignorar_siguiente_movimiento:
			_ignorar_siguiente_movimiento = false
			return
		var delta: Vector2 = limitar_delta(movimiento.relative)
		rotation.y -= delta.x * sensibilidad
		rotation.x = clamp(
			rotation.x - delta.y * sensibilidad,
			deg_to_rad(limite_pitch_min),
			deg_to_rad(limite_pitch_max)
		)

func _process(_delta: float) -> void:
	if _primera_persona:
		return
	# Al inclinar, acortar el brazo para que la camara no cruce el piso.
	spring_length = longitud_segura(position.y, rotation.x, LONGITUD_BASE)
	if _camara != null and _camara.global_position.y < ALTURA_SUELO:
		var posicion: Vector3 = _camara.global_position
		posicion.y = ALTURA_SUELO
		_camara.global_position = posicion

# El pivote sube con el hongo para no mirar por debajo del modelo.
func configurar_tamanio(tamanio: float) -> void:
	_tamanio = maxf(1.0, tamanio)
	if _primera_persona:
		_aplicar_primera_persona()
		return
	position = Vector3(offset_hombro, altura_pivote_para(_tamanio), 0.0)
	spring_length = LONGITUD_BASE

func alternar_primera_persona() -> void:
	_primera_persona = not _primera_persona
	_aplicar_primera_persona()

func _aplicar_primera_persona() -> void:
	if _primera_persona:
		position = Vector3(0.0, altura_ojo_para(_tamanio), 0.0)
		spring_length = 0.0
	else:
		position = Vector3(offset_hombro, altura_pivote_para(_tamanio), 0.0)
		spring_length = LONGITUD_BASE
	if _visual != null:
		_visual.visible = not _primera_persona
	if _camara != null:
		_camara.near = 0.08 if _primera_persona else 0.05

func esta_en_primera_persona() -> bool:
	return _primera_persona

# Altura del pivote en tercera persona, escalada por el tamanio del hongo.
static func altura_pivote_para(tamanio: float) -> float:
	return clampf(1.55 * maxf(1.0, tamanio), ALTURA_PIVOTE_MIN, ALTURA_PIVOTE_MAX)

# Altura de los ojos en primera persona.
static func altura_ojo_para(tamanio: float) -> float:
	return maxf(1.55 * maxf(1.0, tamanio), 1.35)

# Brazo maximo para que la punta no quede por debajo de ALTURA_SUELO.
static func longitud_segura(altura_pivote: float, pitch: float, base: float) -> float:
	var disponible: float = maxf(altura_pivote - ALTURA_SUELO, 0.0)
	var seno: float = absf(sin(pitch))
	if seno < 0.001:
		return base
	return clampf(disponible / seno, 0.6, base)

func recapturar_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Al recapturar, descartar el primer movimiento para que no salte.
	_ignorar_siguiente_movimiento = true

func liberar_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Regla pura: conserva la direccion del movimiento y recorta su longitud.
static func limitar_delta(relativo: Vector2, maximo: float = DELTA_MAXIMO_MOUSE) -> Vector2:
	if maximo <= 0.0:
		return Vector2.ZERO
	return relativo.limit_length(maximo)
