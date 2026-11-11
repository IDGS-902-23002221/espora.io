extends SpringArm3D

# Limite de pixeles por evento: evita que un pico del mouse gire la camara de golpe.
const DELTA_MAXIMO_MOUSE: float = 150.0
# Margen del brazo para que no se pegue a la colision al acercarse al suelo.
const MARGEN_SPRING_ARM: float = 0.2

@export var sensibilidad: float = 0.0025
@export var limite_pitch_min: float = -60.0
@export var limite_pitch_max: float = 60.0

# Tras recuperar foco, el primer movimiento relativo puede venir enorme.
var _ignorar_siguiente_movimiento: bool = false

func _ready() -> void:
	margin = MARGEN_SPRING_ARM
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_ignorar_siguiente_movimiento = true

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausa"):
		_alternar_mouse()
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

func _alternar_mouse() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Al recapturar, descartar el primer movimiento para que no salte.
		_ignorar_siguiente_movimiento = true

# Regla pura: conserva la direccion del movimiento y recorta su longitud.
static func limitar_delta(relativo: Vector2, maximo: float = DELTA_MAXIMO_MOUSE) -> Vector2:
	if maximo <= 0.0:
		return Vector2.ZERO
	return relativo.limit_length(maximo)
