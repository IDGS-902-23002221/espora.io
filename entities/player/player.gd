extends CharacterBody3D

const EsporaScript = preload("res://entities/spore/spore.gd")
# Atacante simulado del debug: el doble supera siempre el umbral de 1.10
# y 2.0 es exacto en binario, sin errores de redondeo.
const MULT_ATACANTE_DEBUG: float = 2.0

signal puntos_cambiados(restantes: int)
signal absorbido

@export var camara: Camera3D
# Escena de la espora y punto frontal desde donde sale el disparo.
@export var escena_espora: PackedScene
@export var punto_disparo: Node3D

var tamanio: float = GameConfig.TAMANIO_INICIAL
var _gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var _tiempo_cooldown: float = 0.0
# Puntos de dano del jugador; el HUD los dibuja.
var _puntos_dano: PuntosDano = PuntosDano.new()
# Ultimo NPC que acerto un impacto valido: crece cuando nos absorbe.
var _atacante_ultimo: Node3D
var _en_reaparicion: bool = false
var _tiempo_reaparicion: float = 0.0

@onready var _visual: Node3D = $Visual
@onready var _colision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	_aplicar_tamanio()
	_puntos_dano.puntos_cambiados.connect(_on_puntos_cambiados)
	_puntos_dano.absorbido.connect(_on_absorbido)

func _physics_process(delta: float) -> void:
	# Durante la reaparicion queda oculto e inmovil: solo corre el cooldown.
	if _en_reaparicion:
		_avanzar_reaparicion(delta)
		return

	# La regeneracion de puntos corre en el jugador, igual que en los NPC.
	_puntos_dano.avanzar_tiempo(delta)
	_actualizar_debug()

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= _gravedad * delta

	var entrada: Vector2 = Input.get_vector(
		"mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras"
	)
	var direccion: Vector3 = _direccion_relativa_a_camara(entrada)
	var velocidad: float = Crecimiento.velocidad_por_tamanio(tamanio, GameConfig.VELOCIDAD_BASE_JUGADOR)
	velocity.x = direccion.x * velocidad
	velocity.z = direccion.z * velocidad

	move_and_slide()
	_mantener_en_arena()
	_actualizar_disparo(delta)

func _actualizar_disparo(delta: float) -> void:
	if _tiempo_cooldown > 0.0:
		_tiempo_cooldown = maxf(0.0, _tiempo_cooldown - delta)
	# Mantener el boton dispara en automatico, pero nunca mas rapido que el cooldown.
	if Input.is_action_pressed("disparar") and _tiempo_cooldown <= 0.0:
		disparar()

func disparar() -> void:
	if escena_espora == null or punto_disparo == null or camara == null:
		return
	var direccion: Vector3 = direccion_disparo_horizontal(camara.global_basis)
	if direccion == Vector3.ZERO:
		return
	var escena: Node = get_tree().current_scene
	if escena == null:
		return

	# La espora del jugador impacta NPCs (capa 2) y nunca al propio jugador.
	var espora: Area3D = EsporaScript.disparar(
		escena_espora, escena, _origen_disparo(direccion), direccion,
		tamanio, self, EsporaScript.CAPA_NPC
	)
	if espora == null:
		return
	_tiempo_cooldown = GameConfig.COOLDOWN_DISPARO_JUGADOR

# Gira el punto frontal segun el yaw de la camara, manteniendo su altura.
func _origen_disparo(direccion: Vector3) -> Vector3:
	var base: Vector3 = punto_disparo.global_position
	var distancia: float = Vector2(
		base.x - global_position.x, base.z - global_position.z
	).length()
	return Vector3(global_position.x, base.y, global_position.z) + direccion * distancia

# Yaw de la camara proyectado al plano XZ; el pitch no afecta el disparo.
static func direccion_disparo_horizontal(base_camara: Basis) -> Vector3:
	return EsporaScript.direccion_horizontal(-base_camara.z)

func consumir_nutriente() -> void:
	tamanio = Crecimiento.crecer(tamanio)
	_aplicar_tamanio()

# Lo llama el NPC absorbido a traves de la referencia que guardo la espora.
func absorber(tamanio_absorbido: float) -> void:
	tamanio = Absorcion.crecimiento_por_absorcion(tamanio, tamanio_absorbido)
	_aplicar_tamanio()

func puntos_actuales() -> int:
	return _puntos_dano.puntos

# Mismo umbral que el NPC. Reusa la proporcion de ReglaTamanio, ya existente.
func recibir_impacto(tamanio_atacante: float, atacante: Node3D) -> void:
	if ReglaTamanio.proporcion(tamanio_atacante, tamanio) < GameConfig.UMBRAL_ATAQUE_ENTRADA:
		return
	# Guardar quien nos acerto: al vaciarnos, ese NPC crece.
	_atacante_ultimo = atacante
	_puntos_dano.recibir_impacto()

# Solo en builds de depuracion: simula un impacto para probar el HUD.
func _actualizar_debug() -> void:
	if not OS.is_debug_build():
		return
	if not Input.is_action_just_pressed("debug_impacto"):
		return
	# Atacante simulado grande: cuenta sin tocar ningun valor de balance.
	recibir_impacto(tamanio * MULT_ATACANTE_DEBUG, null)

func _on_puntos_cambiados(restantes: int) -> void:
	puntos_cambiados.emit(restantes)

func _on_absorbido() -> void:
	absorbido.emit()
	# Diferido: el impacto llega desde el Area3D de la espora.
	_iniciar_reaparicion.call_deferred()

func _iniciar_reaparicion() -> void:
	# El que nos vacio crece con el tamano que teniamos (regla congelada).
	if _atacante_ultimo != null and _atacante_ultimo.has_method("absorber"):
		_atacante_ultimo.absorber(tamanio)
	_atacante_ultimo = null

	# Reaparece mas chico (con piso) en otro punto y con cooldown.
	tamanio = Absorcion.tamanio_reaparicion(tamanio)
	_aplicar_tamanio()
	_reubicar_en_arena()
	_en_reaparicion = true
	_tiempo_reaparicion = GameConfig.COOLDOWN_REAPARICION_JUGADOR
	_tiempo_cooldown = 0.0
	velocity = Vector3.ZERO
	_visual.visible = false
	# Diferido: seguimos dentro del callback del Area de la espora.
	_colision.set_deferred("disabled", true)

func _avanzar_reaparicion(delta: float) -> void:
	_tiempo_reaparicion -= delta
	if _tiempo_reaparicion > 0.0:
		return
	_en_reaparicion = false
	# Puntos llenos: el HUD vuelve a 3 cian.
	_puntos_dano.reiniciar()
	_visual.visible = true
	_colision.set_deferred("disabled", false)

func _reubicar_en_arena() -> void:
	# Misma distribucion uniforme que el spawner y el NPC (calculo copiado).
	var angulo: float = randf() * TAU
	var radio: float = GameConfig.RADIO_MAPA * sqrt(randf())
	global_position = Vector3(cos(angulo) * radio, global_position.y, sin(angulo) * radio)

func _aplicar_tamanio() -> void:
	if _visual != null:
		_visual.scale = Vector3.ONE * tamanio
	if _colision != null:
		_colision.scale = Vector3.ONE * tamanio
		_colision.position = Vector3(0.0, 0.8 * tamanio, 0.0)

func _direccion_relativa_a_camara(entrada: Vector2) -> Vector3:
	if camara == null or entrada.length_squared() == 0.0:
		return Vector3.ZERO

	var base: Basis = camara.global_basis
	var adelante: Vector3 = -base.z
	adelante.y = 0.0
	adelante = adelante.normalized()

	var derecha: Vector3 = base.x
	derecha.y = 0.0
	derecha = derecha.normalized()

	return (derecha * entrada.x + adelante * -entrada.y).normalized()

func _mantener_en_arena() -> void:
	var plano: Vector2 = Vector2(global_position.x, global_position.z)
	if plano.length() > GameConfig.RADIO_MAPA:
		plano = plano.normalized() * GameConfig.RADIO_MAPA
		global_position.x = plano.x
		global_position.z = plano.y
