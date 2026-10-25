extends SpringArm3D

@export var sensibilidad: float = 0.0025
@export var limite_pitch_min: float = -60.0
@export var limite_pitch_max: float = 60.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("pausa"):
		_alternar_mouse()
		return

	if evento is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var movimiento: InputEventMouseMotion = evento
		rotation.y -= movimiento.relative.x * sensibilidad
		rotation.x = clamp(
			rotation.x - movimiento.relative.y * sensibilidad,
			deg_to_rad(limite_pitch_min),
			deg_to_rad(limite_pitch_max)
		)

func _alternar_mouse() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
