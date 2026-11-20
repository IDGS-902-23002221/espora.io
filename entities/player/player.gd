extends CharacterBody3D

const EsporaScript = preload("res://entities/spore/spore.gd")
const EspeciesScript = preload("res://core/especies.gd")
# Atacante simulado del debug: el doble supera siempre el umbral de 1.10
# y 2.0 es exacto en binario, sin errores de redondeo.
const MULT_ATACANTE_DEBUG: float = 2.0
# El frente local del modelo es +Z; el desfase PI lo alinea con el frente de la camara.
const DESFASE_MODELO: float = PI
# Offset local del punto de disparo (al frente del modelo); se rota con el cuerpo.
const POSICION_DISPARO: Vector3 = Vector3(0.0, 0.8, 1.2)

signal puntos_cambiados(restantes: int)
signal absorbido
signal nutriente_consumido
signal absorcion_realizada(tamanio_absorbido: float)

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
var _tiempo_escudo: float = 0.0
var _escudo_visual: MeshInstance3D
var _tiempo_velocidad: float = 0.0
var _velocidad_visual: MeshInstance3D
var _material_cuerpo: StandardMaterial3D
var _material_sombrero: StandardMaterial3D
var _modelo_skin: Node3D

@onready var _visual: Node3D = $Visual
@onready var _colision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	_aplicar_tamanio()
	_crear_escudo_visual()
	_crear_velocidad_visual()
	_crear_materiales_jugador()
	_aplicar_skin_actual()
	_crear_marcador_disparo()
	_puntos_dano.puntos_cambiados.connect(_on_puntos_cambiados)
	_puntos_dano.absorbido.connect(_on_absorbido)

func _physics_process(delta: float) -> void:
	_actualizar_escudo(delta)
	_actualizar_velocidad(delta)
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
	velocidad *= multiplicador_velocidad(_tiempo_velocidad)
	velocity.x = direccion.x * velocidad
	velocity.z = direccion.z * velocidad

	move_and_slide()
	_mantener_en_arena()
	_actualizar_orientacion()
	_actualizar_animacion()
	_actualizar_disparo(delta)

func _actualizar_disparo(delta: float) -> void:
	if _tiempo_cooldown > 0.0:
		_tiempo_cooldown = maxf(0.0, _tiempo_cooldown - delta)
	# Mantener el boton dispara en automatico, pero nunca mas rapido que el cooldown.
	if Input.is_action_pressed("disparar") and _tiempo_cooldown <= 0.0:
		disparar()

# El cuerpo entero sigue el yaw horizontal de la camara; nunca se inclina.
func _actualizar_orientacion() -> void:
	if camara == null or _visual == null or punto_disparo == null:
		return
	var yaw: float = yaw_cuerpo(-camara.global_basis.z, DESFASE_MODELO)
	_visual.rotation.y = yaw
	punto_disparo.rotation.y = yaw
	punto_disparo.position = POSICION_DISPARO.rotated(Vector3.UP, yaw)

# Yaw para que el frente local (-Z) del modelo apunte a la direccion.
static func yaw_cuerpo(direccion: Vector3, desfase: float = 0.0) -> float:
	var plana: Vector3 = Vector3(direccion.x, 0.0, direccion.z)
	if plana.length_squared() == 0.0:
		return desfase
	plana = plana.normalized()
	return atan2(-plana.x, -plana.z) + desfase

# La skin camina cuando el jugador se mueve; quieta vuelve a Idle.
func _actualizar_animacion() -> void:
	if _modelo_skin == null:
		return
	EspeciesScript.animar_modelo(_modelo_skin, Vector2(velocity.x, velocity.z).length())

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
		tamanio, self, EsporaScript.mascara_para(false)
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

func consumir_nutriente(multiplicador: float = 1.0) -> void:
	tamanio = Crecimiento.crecer(tamanio, multiplicador)
	_aplicar_tamanio()
	# Despues de actualizar el tamano, para que el maximo no quede atras.
	nutriente_consumido.emit()

func activar_escudo() -> void:
	_tiempo_escudo = GameConfig.DURACION_ESPORA_ESCUDO
	if _escudo_visual != null:
		_escudo_visual.visible = true

func _actualizar_escudo(delta: float) -> void:
	if _tiempo_escudo <= 0.0:
		return
	_tiempo_escudo = maxf(0.0, _tiempo_escudo - delta)
	if _tiempo_escudo == 0.0 and _escudo_visual != null:
		_escudo_visual.visible = false

func activar_velocidad() -> void:
	_tiempo_velocidad = GameConfig.DURACION_ESPORA_VELOZ
	if _velocidad_visual != null:
		_velocidad_visual.visible = true

func _actualizar_velocidad(delta: float) -> void:
	if _tiempo_velocidad <= 0.0:
		return
	_tiempo_velocidad = maxf(0.0, _tiempo_velocidad - delta)
	if _velocidad_visual == null:
		return
	_velocidad_visual.visible = _tiempo_velocidad > 0.0
	if _velocidad_visual.visible:
		_velocidad_visual.rotation.y += delta * 6.0

static func multiplicador_velocidad(tiempo: float) -> float:
	if tiempo > 0.0:
		return GameConfig.MULT_VELOCIDAD_ESPORA_VELOZ
	return 1.0

# Lo llama el NPC absorbido a traves de la referencia que guardo la espora.
func absorber(tamanio_absorbido: float) -> void:
	tamanio = Absorcion.crecimiento_por_absorcion(tamanio, tamanio_absorbido)
	_aplicar_tamanio()
	absorcion_realizada.emit(tamanio_absorbido)

func puntos_actuales() -> int:
	return _puntos_dano.puntos

# Mientras reaparece no puede ser objetivo de los NPC.
func esta_activo() -> bool:
	return not _en_reaparicion

# Regla pura para tests: el escudo activo ignora cualquier impacto.
static func bloquea_impacto(tiempo_escudo: float) -> bool:
	return tiempo_escudo > 0.0

# Mismo umbral que el NPC. Reusa la proporcion de ReglaTamanio, ya existente.
func recibir_impacto(tamanio_atacante: float, atacante: Node3D) -> void:
	if bloquea_impacto(_tiempo_escudo):
		return
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
	# Sin intentos (o partida terminada) no hay reaparicion: derrota.
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		var progreso: Puntaje = gm.get("progreso")
		if progreso == null or progreso.intentos <= 0 or not bool(gm.call("esta_jugando")):
			return

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

func _crear_escudo_visual() -> void:
	_escudo_visual = MeshInstance3D.new()
	var esfera: SphereMesh = SphereMesh.new()
	esfera.radius = 1.0
	esfera.height = 2.0
	esfera.radial_segments = 16
	esfera.rings = 8
	_escudo_visual.mesh = esfera
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.3, 1.0, 0.55, 0.22)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.9, 0.35)
	material.emission_energy_multiplier = 1.5
	_escudo_visual.material_override = material
	_escudo_visual.position = Vector3(0.0, 0.95, 0.0)
	_escudo_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_escudo_visual.visible = false
	_visual.add_child(_escudo_visual)

func _crear_velocidad_visual() -> void:
	_velocidad_visual = MeshInstance3D.new()
	var toro: TorusMesh = TorusMesh.new()
	toro.inner_radius = 0.55
	toro.outer_radius = 0.85
	toro.rings = 16
	toro.ring_segments = 8
	_velocidad_visual.mesh = toro
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.55, 0.35, 1.0, 0.55)
	material.emission_enabled = true
	material.emission = Color(0.45, 0.2, 1.0)
	material.emission_energy_multiplier = 2.0
	_velocidad_visual.material_override = material
	_velocidad_visual.position = Vector3(0.0, 0.15, 0.0)
	_velocidad_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_velocidad_visual.visible = false
	_visual.add_child(_velocidad_visual)

# Punto de disparo visible: una esfera chica emisiva en el offset del disparo.
func _crear_marcador_disparo() -> void:
	if punto_disparo == null:
		return
	var marcador: Node3D = Node3D.new()
	marcador.name = "MarcadorDisparo"
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.albedo_color = Color(0.5, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.3, 0.95, 1.0)
	material.emission_energy_multiplier = 2.0

	var barra_horizontal: MeshInstance3D = MeshInstance3D.new()
	var caja_h: BoxMesh = BoxMesh.new()
	caja_h.size = Vector3(0.28, 0.05, 0.05)
	barra_horizontal.mesh = caja_h
	barra_horizontal.material_override = material
	barra_horizontal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marcador.add_child(barra_horizontal)

	var barra_vertical: MeshInstance3D = MeshInstance3D.new()
	var caja_v: BoxMesh = BoxMesh.new()
	caja_v.size = Vector3(0.05, 0.28, 0.05)
	barra_vertical.mesh = caja_v
	barra_vertical.material_override = material
	barra_vertical.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marcador.add_child(barra_vertical)

	punto_disparo.add_child(marcador)

func _crear_materiales_jugador() -> void:
	_material_cuerpo = StandardMaterial3D.new()
	_material_sombrero = StandardMaterial3D.new()
	var cuerpo: MeshInstance3D = _visual.get_node_or_null("Cuerpo") as MeshInstance3D
	var sombrero: MeshInstance3D = _visual.get_node_or_null("Sombrero") as MeshInstance3D
	if cuerpo != null:
		cuerpo.material_override = _material_cuerpo
	if sombrero != null:
		sombrero.material_override = _material_sombrero

func aplicar_skin(nombre: String) -> void:
	if _material_cuerpo == null or _material_sombrero == null:
		return
	var datos: Dictionary = EspeciesScript.colores_skin(nombre)
	_material_cuerpo.albedo_color = datos["cuerpo"]
	_material_sombrero.albedo_color = datos["sombrero"]
	_material_sombrero.emission_enabled = bool(datos["emision"])
	if _material_sombrero.emission_enabled:
		_material_sombrero.emission = datos["sombrero"]
		_material_sombrero.emission_energy_multiplier = float(datos["energia"])
	var luz: OmniLight3D = get_node_or_null("LuzJugador") as OmniLight3D
	if luz != null:
		luz.light_color = datos["luz"]
		luz.light_energy = float(datos["luz_energia"])
	_quitar_modelo_skin()
	var ruta: String = EspeciesScript.modelo_para_skin(nombre)
	if EspeciesScript.modelo_disponible(ruta):
		var escena: PackedScene = load(ruta) as PackedScene
		if escena != null:
			var modelo: Node3D = escena.instantiate() as Node3D
			_visual.add_child(modelo)
			EspeciesScript.normalizar_modelo(modelo)
			if bool(datos["emision"]):
				EspeciesScript.aplicar_emision_modelo(modelo, datos["sombrero"], float(datos["energia"]))
			EspeciesScript.reproducir_idle(modelo)
			_modelo_skin = modelo
			_ocultar_primitivas(true)
			return
	_ocultar_primitivas(false)

func _quitar_modelo_skin() -> void:
	if _modelo_skin != null:
		_modelo_skin.queue_free()
		_modelo_skin = null

func _ocultar_primitivas(ocultar: bool) -> void:
	var cuerpo: MeshInstance3D = _visual.get_node_or_null("Cuerpo") as MeshInstance3D
	var sombrero: MeshInstance3D = _visual.get_node_or_null("Sombrero") as MeshInstance3D
	if cuerpo != null:
		cuerpo.visible = not ocultar
	if sombrero != null:
		sombrero.visible = not ocultar

func _aplicar_skin_actual() -> void:
	var skin: String = EspeciesScript.SKIN_CLASICO
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null and gm.get("skin_jugador") != null:
		skin = str(gm.get("skin_jugador"))
	aplicar_skin(skin)

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
