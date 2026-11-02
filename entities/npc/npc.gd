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
# Altura fija del disparo: 0.8 entra en cualquier capsula (todas empiezan en y=0),
# incluso cuando el NPC es mucho mas grande que su objetivo. Disparar al centro
# propio pasaba por encima de los hongos chicos.
const ALTURA_DISPARO: float = 0.8
# Cada cuanto se vuelve a elegir el hongo objetivo (no por frame).
const INTERVALO_OBJETIVO: float = 0.5

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
# Objetivo actual: el hongo mas cercano dentro del radio (jugador u otro NPC).
var _objetivo: Node3D
var _objetivo_posicion: Vector3 = Vector3.ZERO
var _objetivo_tamanio: float = 0.0
var _tiempo_objetivo: float = 0.0
# Config de la horda actual, cacheada por indice para no leerla cada frame.
var _horda_indice: int = -1
var _horda_config: Dictionary = {}
# Autoload por ruta: `--check-only` valida el script sin cargar autoloads.
var _game_manager: Node

@onready var _visual: Node3D = $Visual
@onready var _colision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Grupo para que los demas NPC puedan elegirlo como objetivo.
	add_to_group("npcs")
	_game_manager = get_node_or_null("/root/GameManager")
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
	_actualizar_objetivo(delta)
	_actualizar_estado(delta)
	_actualizar_disparo(delta)
	var direccion: Vector3 = _direccion_actual(delta)
	var velocidad_base: float = float(_config_horda()["velocidad_npc"])
	var velocidad: float = Crecimiento.velocidad_por_tamanio(tamanio, velocidad_base)
	velocity.x = direccion.x * velocidad
	velocity.z = direccion.z * velocidad

	move_and_slide()
	_mantener_en_arena()

func _actualizar_estado(delta: float) -> void:
	if _objetivo == null:
		if _tiempo_estado >= GameConfig.TIEMPO_MIN_ESTADO:
			_cambiar_estado(ReglaTamanio.EstadoTamanio.NEUTRAL)
		else:
			_tiempo_estado += delta
		return

	var proporcion_actual: float = ReglaTamanio.proporcion(tamanio, _objetivo_tamanio)
	var siguiente: int = ReglaTamanio.siguiente_estado(_estado, proporcion_actual, _tiempo_estado)
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
			direccion = _direccion_hacia(_objetivo_posicion)
		ReglaTamanio.EstadoTamanio.HUIR:
			direccion = -_direccion_hacia(_objetivo_posicion)
		_:
			_tiempo_deambular += delta
			if _tiempo_deambular >= intervalo_deambular:
				_elegir_direccion_deambular()
			direccion = _direccion_deambular
	return _evitar_borde(direccion)

func _direccion_hacia(objetivo: Vector3) -> Vector3:
	var direccion: Vector3 = objetivo - global_position
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

func _tamanio_de(nodo: Node3D) -> float:
	var valor: Variant = nodo.get("tamanio")
	if valor == null:
		return GameConfig.TAMANIO_INICIAL
	return float(valor)

func _es_activo(nodo: Node3D) -> bool:
	if nodo.has_method("esta_activo"):
		return bool(nodo.call("esta_activo"))
	return true

func _radio_deteccion() -> float:
	return float(_config_horda()["radio_deteccion_npc"])

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

# Config de la horda actual; se refresca solo cuando cambia el indice.
func _config_horda() -> Dictionary:
	if _game_manager == null:
		# Sin autoload (por ejemplo, check-only): primera horda.
		return Hordas.configuracion(0)
	var actual: int = int(_game_manager.get("indice_horda"))
	if actual != _horda_indice:
		_horda_indice = actual
		_horda_config = _game_manager.call("configuracion_horda")
	return _horda_config

# Refresca el objetivo cada INTERVALO_OBJETIVO; entre refrescos solo actualiza
# su posicion/tamano para no recorrer candidatos por frame.
func _actualizar_objetivo(delta: float) -> void:
	_tiempo_objetivo -= delta
	var recargar: bool = _tiempo_objetivo <= 0.0
	if _objetivo != null and (not is_instance_valid(_objetivo) or not _es_activo(_objetivo)):
		recargar = true
	if recargar:
		_objetivo = _elegir_objetivo()
		_tiempo_objetivo = INTERVALO_OBJETIVO
	if _objetivo == null:
		_objetivo_posicion = global_position
		_objetivo_tamanio = 0.0
		return
	_objetivo_posicion = _objetivo.global_position
	_objetivo_tamanio = _tamanio_de(_objetivo)

func _elegir_objetivo() -> Node3D:
	var candidatos: Array = []
	if jugador != null and _es_activo(jugador):
		candidatos.append(_candidato(jugador))
	# Entre NPC se detectan a menor distancia para que el ecosistema no sea caotico.
	var radio_npc: float = _radio_deteccion() * GameConfig.FACTOR_RADIO_NPC_NPC
	for nodo in get_tree().get_nodes_in_group("npcs"):
		var otro: Node3D = nodo as Node3D
		if otro == null or otro == self or not _es_activo(otro):
			continue
		if _distancia_horizontal(otro.global_position) > radio_npc:
			continue
		candidatos.append(_candidato(otro))
	var elegido: Dictionary = elegir_objetivo(global_position, candidatos, _radio_deteccion())
	if elegido.is_empty():
		return null
	return elegido["nodo"] as Node3D

func _candidato(nodo: Node3D) -> Dictionary:
	return {
		"posicion": nodo.global_position,
		"tamanio": _tamanio_de(nodo),
		"nodo": nodo,
	}

# Resuelve donde interceptar al objetivo: |D + V*t| = v*t en el plano XZ.
# Si no hay solucion positiva (objetivo mas rapido que la espora), apunta al actual.
static func punto_intercepcion(origen: Vector3, posicion_objetivo: Vector3, velocidad_objetivo: Vector3) -> Vector3:
	var d: Vector2 = Vector2(posicion_objetivo.x - origen.x, posicion_objetivo.z - origen.z)
	var v: Vector2 = Vector2(velocidad_objetivo.x, velocidad_objetivo.z)
	var rapidez: float = GameConfig.VELOCIDAD_ESPORA
	var a: float = v.dot(v) - rapidez * rapidez
	var b: float = 2.0 * d.dot(v)
	var c: float = d.dot(d)
	var tiempo: float = -1.0
	var disc: float = b * b - 4.0 * a * c
	if absf(a) > 0.0001 and disc >= 0.0:
		var raiz: float = sqrt(disc)
		var t1: float = (-b - raiz) / (2.0 * a)
		var t2: float = (-b + raiz) / (2.0 * a)
		if t1 > 0.0 and t2 > 0.0:
			tiempo = minf(t1, t2)
		elif t1 > 0.0:
			tiempo = t1
		elif t2 > 0.0:
			tiempo = t2
	if tiempo <= 0.0:
		return posicion_objetivo
	var punto: Vector3 = posicion_objetivo + velocidad_objetivo * tiempo
	punto.y = posicion_objetivo.y
	return punto

# Elige el candidato mas cercano dentro del radio; vacio si no hay.
static func elegir_objetivo(posicion: Vector3, candidatos: Array, radio: float) -> Dictionary:
	var mejor: Dictionary = {}
	var mejor_distancia: float = radio
	for candidato in candidatos:
		var p: Vector3 = candidato["posicion"]
		var d: float = Vector2(p.x - posicion.x, p.z - posicion.z).length()
		if d <= mejor_distancia:
			mejor_distancia = d
			mejor = candidato
	return mejor

func esta_activo() -> bool:
	return not _en_cooldown

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

# El NPC tambien come nutrientes: crece igual que el jugador.
func consumir_nutriente() -> void:
	tamanio = Crecimiento.crecer(tamanio)
	_aplicar_tamanio()

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
	if _objetivo == null:
		return
	# Si no supera el umbral de dano, la espora no contaria: no gastar disparo.
	if not impacto_cuenta(tamanio, _objetivo_tamanio):
		return
	var radio: float = _radio_deteccion()
	var distancia: float = _distancia_horizontal(_objetivo_posicion)
	if not puede_disparar(_estado, distancia, radio, _tiempo_disparo):
		return
	_disparar()

func _disparar() -> void:
	if _objetivo == null:
		return
	var velocidad_objetivo: Vector3 = Vector3.ZERO
	var valor_velocidad: Variant = _objetivo.get("velocity")
	if valor_velocidad != null:
		velocidad_objetivo = valor_velocidad
	var punto: Vector3 = punto_intercepcion(
		global_position, _objetivo_posicion, velocidad_objetivo
	)
	var direccion: Vector3 = _direccion_hacia(punto)
	if direccion == Vector3.ZERO:
		return
	var escena: Node = get_tree().current_scene
	if escena == null:
		return
	var origen: Vector3 = global_position + Vector3(0.0, ALTURA_DISPARO, 0.0)
	# La espora del NPC impacta al jugador y a otros NPC (ecosistema).
	# Va con anticipacion: se puede esquivar moviendose.
	var espora: Area3D = EsporaScript.disparar(
		EscenaEspora, escena, origen, direccion, tamanio, self,
		EsporaScript.mascara_para(true)
	)
	if espora == null:
		return
	_tiempo_disparo = float(_config_horda()["cooldown_disparo_npc"])

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
