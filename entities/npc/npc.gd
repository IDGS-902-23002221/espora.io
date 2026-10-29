extends CharacterBody3D

const EsporaScript = preload("res://entities/spore/spore.gd")
# Precargada: evita un @export manual que pueda quedar en null.
const EscenaEspora: PackedScene = preload("res://entities/spore/spore.tscn")

@export var jugador: Node3D
@export var tamanio_inicial: float = 1.0
@export var mostrar_estado: bool = false
@export var etiqueta_estado: Label3D
@export var intervalo_deambular: float = 2.0
@export var margen_borde: float = 2.0

# Misma altura que usan los NPC colocados en la arena.
const ALTURA_REAPARICION: float = 0.1

var tamanio: float = 1.0
# Puntos de dano propios; se vacian con impactos de esporas validos.
var _puntos_dano: PuntosDano = PuntosDano.new()
var _estado: int = ReglaTamanio.EstadoTamanio.NEUTRAL
var _tiempo_estado: float = 0.0
var _tiempo_deambular: float = 0.0
var _direccion_deambular: Vector3 = Vector3.FORWARD
var _gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
# Ultimo atacante valido: lo usa la absorcion para hacer crecer al que disparo.
var _atacante_ultimo: Node3D
var _en_cooldown: bool = false
var _tiempo_cooldown: float = 0.0
var _tiempo_disparo: float = 0.0

@onready var _visual: Node3D = $Visual
@onready var _colision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	tamanio = tamanio_inicial
	_aplicar_tamanio()
	# La etiqueta se refresca sola cuando cambian los puntos (impacto o regeneracion).
	_puntos_dano.puntos_cambiados.connect(_on_puntos_cambiados)
	# Al vaciarse los 3 puntos, el NPC absorbe/respawnea.
	_puntos_dano.absorbido.connect(_on_absorbido)
	_actualizar_etiqueta()
	_elegir_direccion_deambular()

func _physics_process(delta: float) -> void:
	# Durante el cooldown queda oculto, congelado e intocable.
	if _en_cooldown:
		_avanzar_cooldown(delta)
		return

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= _gravedad * delta

	# La regeneracion (4 s por punto) corre en el NPC, no en el proyectil.
	_puntos_dano.avanzar_tiempo(delta)
	_actualizar_estado(delta)
	_actualizar_disparo(delta)
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

# Un impacto solo cuenta si el atacante supera el umbral de ataque de entrada.
@warning_ignore("unused_parameter")
func recibir_impacto(tamanio_atacante: float, atacante: Node3D) -> void:
	if _en_cooldown:
		return
	if not impacto_cuenta(tamanio_atacante, tamanio):
		return
	# Guardar al atacante: al llegar a 0 puntos se lo usa para absorber.
	_atacante_ultimo = atacante
	# Delegar en PuntosDano mantiene la regla de 3 impactos y la regeneracion.
	_puntos_dano.recibir_impacto()

# Lo llama el jugador absorbido; quien absorbe crece (regla congelada).
func absorber(tamanio_absorbido: float) -> void:
	tamanio = Absorcion.crecimiento_por_absorcion(tamanio, tamanio_absorbido)
	_aplicar_tamanio()

# Regla pura duplicada del umbral para poder testearla sin nodo.
static func impacto_cuenta(tamanio_atacante: float, tamanio_objetivo: float) -> bool:
	return ReglaTamanio.proporcion(tamanio_atacante, tamanio_objetivo) >= GameConfig.UMBRAL_ATAQUE_ENTRADA

# Condiciones puras para disparar: perseguir, dentro del radio y sin cooldown.
static func puede_disparar(estado: int, distancia: float, radio: float, tiempo_cooldown: float) -> bool:
	if estado != ReglaTamanio.EstadoTamanio.PERSEGUIR:
		return false
	if tiempo_cooldown > 0.0:
		return false
	return distancia <= radio

func _actualizar_disparo(delta: float) -> void:
	if _tiempo_disparo > 0.0:
		_tiempo_disparo = maxf(0.0, _tiempo_disparo - delta)
	if jugador == null:
		return
	# Si no supera el umbral de dano, la espora no contaria: no gastar disparo.
	if not impacto_cuenta(tamanio, _tamanio_del_jugador()):
		return
	var radio: float = float(GameConfig.HORDAS[0]["radio_deteccion_npc"])
	var distancia: float = _distancia_horizontal(jugador.global_position)
	if not puede_disparar(_estado, distancia, radio, _tiempo_disparo):
		return
	_disparar()

func _disparar() -> void:
	if jugador == null:
		return
	var direccion: Vector3 = _direccion_desde_jugador()
	if direccion == Vector3.ZERO:
		return
	var escena: Node = get_tree().current_scene
	if escena == null:
		return
	# Centro de la colision: ya escala con el tamano, sin constante nueva.
	var origen: Vector3 = global_position + Vector3(0.0, _colision.position.y, 0.0)
	# La espora del NPC solo impacta al jugador (capa 1).
	var espora: Area3D = EsporaScript.disparar(
		EscenaEspora, escena, origen, direccion, tamanio, self, EsporaScript.CAPA_JUGADOR
	)
	if espora == null:
		return
	_tiempo_disparo = float(GameConfig.HORDAS[0]["cooldown_disparo_npc"])

func _on_puntos_cambiados(_restantes: int) -> void:
	_actualizar_etiqueta()

func _actualizar_etiqueta() -> void:
	if etiqueta_estado == null:
		return
	etiqueta_estado.visible = mostrar_estado
	if not mostrar_estado:
		return
	var estado_texto: String
	match _estado:
		ReglaTamanio.EstadoTamanio.PERSEGUIR:
			estado_texto = "PERSEGUIR"
		ReglaTamanio.EstadoTamanio.HUIR:
			estado_texto = "HUIR"
		_:
			estado_texto = "NEUTRAL"
	# Incluye los puntos restantes para depuracion.
	etiqueta_estado.text = "%s  %d/%d" % [
		estado_texto, _puntos_dano.puntos, GameConfig.IMPACTOS_PARA_ABSORBER
	]

# Diferido: el impacto llega desde el Area de la espora; movemos al NPC fuera de ese callback.
func _on_absorbido() -> void:
	_absorber_y_reaparecer.call_deferred()

func _absorber_y_reaparecer() -> void:
	var tamanio_absorbido: float = tamanio
	# El atacante crece usando el tamano que tenia este NPC al ser absorbido.
	if _atacante_ultimo != null and _atacante_ultimo.has_method("absorber"):
		_atacante_ultimo.absorber(tamanio_absorbido)
	_atacante_ultimo = null

	# Reaparece mas chico, con los puntos llenos y en otro punto de la arena.
	tamanio = Absorcion.tamanio_reaparicion(tamanio_absorbido)
	_aplicar_tamanio()
	_puntos_dano.reiniciar()
	_estado = ReglaTamanio.EstadoTamanio.NEUTRAL
	_tiempo_estado = 0.0
	_elegir_direccion_deambular()
	_reubicar_en_arena()
	_iniciar_cooldown()

func _reubicar_en_arena() -> void:
	# Misma distribucion uniforme que world/nutrient_spawner.gd. Se copia el
	# calculo porque el spawner no lo expone y esta fuera del alcance del ticket.
	var angulo: float = randf() * TAU
	var radio: float = GameConfig.RADIO_MAPA * sqrt(randf())
	global_position = Vector3(cos(angulo) * radio, ALTURA_REAPARICION, sin(angulo) * radio)

func _iniciar_cooldown() -> void:
	_en_cooldown = true
	_tiempo_cooldown = GameConfig.COOLDOWN_REAPARICION_NPC
	velocity = Vector3.ZERO
	_visual.visible = false
	if etiqueta_estado != null:
		etiqueta_estado.visible = false
	# Diferido: seguimos dentro del callback del Area de la espora.
	_colision.set_deferred("disabled", true)

func _avanzar_cooldown(delta: float) -> void:
	_tiempo_cooldown -= delta
	if _tiempo_cooldown > 0.0:
		return
	_en_cooldown = false
	_reactivar()

func _reactivar() -> void:
	_visual.visible = true
	_colision.set_deferred("disabled", false)
	# Respeta mostrar_estado y muestra los puntos ya reseteados.
	_actualizar_etiqueta()
