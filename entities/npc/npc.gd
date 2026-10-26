extends CharacterBody3D

@export var jugador: Node3D
@export var tamanio_inicial: float = 1.0
@export var mostrar_estado: bool = false
@export var etiqueta_estado: Label3D
@export var intervalo_deambular: float = 2.0
@export var margen_borde: float = 2.0

var tamanio: float = 1.0
var _estado: int = ReglaTamanio.EstadoTamanio.NEUTRAL
var _tiempo_estado: float = 0.0
var _tiempo_deambular: float = 0.0
var _direccion_deambular: Vector3 = Vector3.FORWARD
var _gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@onready var _visual: Node3D = $Visual
@onready var _colision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	tamanio = tamanio_inicial
	_aplicar_tamanio()
	_actualizar_etiqueta()
	_elegir_direccion_deambular()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= _gravedad * delta

	_actualizar_estado(delta)
	var direccion: Vector3 = _direccion_actual(delta)
	var velocidad_base: float = float(GameConfig.HORDAS[0]["velocidad_npc"])
	var velocidad: float = Crecimiento.velocidad_por_tamanio(tamanio, velocidad_base)
	velocity.x = direccion.x * velocidad
	velocity.z = direccion.z * velocidad

	move_and_slide()
	_mantener_en_arena()

func _actualizar_estado(delta: float) -> void:
	if jugador == null:
		_cambiar_estado(ReglaTamanio.EstadoTamanio.NEUTRAL)
		return

	var tamanio_jugador: float = _tamanio_del_jugador()
	var proporcion_actual: float = ReglaTamanio.proporcion(tamanio, tamanio_jugador)
	var radio: float = float(GameConfig.HORDAS[0]["radio_deteccion_npc"])
	var distancia: float = _distancia_horizontal(jugador.global_position)

	var siguiente: int
	if distancia > radio:
		if _tiempo_estado >= GameConfig.TIEMPO_MIN_ESTADO:
			siguiente = ReglaTamanio.EstadoTamanio.NEUTRAL
		else:
			siguiente = _estado
	else:
		siguiente = ReglaTamanio.siguiente_estado(_estado, proporcion_actual, _tiempo_estado)

	if siguiente != _estado:
		_cambiar_estado(siguiente)
	else:
		_tiempo_estado += delta

func _cambiar_estado(nuevo: int) -> void:
	if nuevo == _estado:
		return
	_estado = nuevo
	_tiempo_estado = 0.0
	if nuevo == ReglaTamanio.EstadoTamanio.NEUTRAL:
		_elegir_direccion_deambular()
	_actualizar_etiqueta()

func _direccion_actual(delta: float) -> Vector3:
	var direccion: Vector3 = Vector3.ZERO
	match _estado:
		ReglaTamanio.EstadoTamanio.PERSEGUIR:
			direccion = _direccion_desde_jugador()
		ReglaTamanio.EstadoTamanio.HUIR:
			direccion = -_direccion_desde_jugador()
		_:
			_tiempo_deambular += delta
			if _tiempo_deambular >= intervalo_deambular:
				_elegir_direccion_deambular()
			direccion = _direccion_deambular
	return _evitar_borde(direccion)

func _direccion_desde_jugador() -> Vector3:
	if jugador == null:
		return Vector3.ZERO
	var direccion: Vector3 = jugador.global_position - global_position
	direccion.y = 0.0
	if direccion.length_squared() == 0.0:
		return Vector3.ZERO
	return direccion.normalized()

func _evitar_borde(direccion: Vector3) -> Vector3:
	var plano: Vector2 = Vector2(global_position.x, global_position.z)
	var limite: float = GameConfig.RADIO_MAPA - margen_borde
	if plano.length() > limite:
		return -Vector3(plano.x, 0.0, plano.y).normalized()
	return direccion

func _mantener_en_arena() -> void:
	var plano: Vector2 = Vector2(global_position.x, global_position.z)
	if plano.length() > GameConfig.RADIO_MAPA:
		plano = plano.normalized() * GameConfig.RADIO_MAPA
		global_position.x = plano.x
		global_position.z = plano.y

func _tamanio_del_jugador() -> float:
	var valor: Variant = jugador.get("tamanio")
	if valor == null:
		return GameConfig.TAMANIO_INICIAL
	return float(valor)

func _distancia_horizontal(objetivo: Vector3) -> float:
	return Vector2(objetivo.x - global_position.x, objetivo.z - global_position.z).length()

func _elegir_direccion_deambular() -> void:
	_tiempo_deambular = 0.0
	_direccion_deambular = Vector3(
		randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)
	)
	if _direccion_deambular.length_squared() == 0.0:
		_direccion_deambular = Vector3.FORWARD
	else:
		_direccion_deambular = _direccion_deambular.normalized()

func _aplicar_tamanio() -> void:
	if _visual != null:
		_visual.scale = Vector3.ONE * tamanio
	if _colision != null:
		_colision.scale = Vector3.ONE * tamanio
		_colision.position = Vector3(0.0, 0.8 * tamanio, 0.0)

func _actualizar_etiqueta() -> void:
	if etiqueta_estado == null:
		return
	etiqueta_estado.visible = mostrar_estado
	if not mostrar_estado:
		return
	match _estado:
		ReglaTamanio.EstadoTamanio.PERSEGUIR:
			etiqueta_estado.text = "PERSEGUIR"
		ReglaTamanio.EstadoTamanio.HUIR:
			etiqueta_estado.text = "HUIR"
		_:
			etiqueta_estado.text = "NEUTRAL"
