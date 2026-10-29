extends Area3D

# Capas de fisica del proyecto (project.godot, layer_names).
const CAPA_JUGADOR: int = 1
const CAPA_NPC: int = 2

# Quien disparo la espora y su tamano al salir; lo usa el NPC al impactar
# y la absorcion al vaciar los puntos.
var atacante: Node3D
var tamanio_atacante: float = 0.0

var _direccion: Vector3 = Vector3.ZERO
var _tiempo_vida: float = 0.0
# Evita contar dos veces el impacto si el Area toca varios cuerpos en el mismo frame.
var _impactado: bool = false

func _ready() -> void:
	# Deteccion por Area contra el cuerpo del NPC (capa 2), no por grupos.
	body_entered.connect(_on_body_entered)

# El jugador llama esto justo despues de sumar la espora a la escena.
func configurar(direccion: Vector3, tamanio: float, quien: Node3D) -> void:
	_direccion = direccion_horizontal(direccion)
	tamanio_atacante = tamanio
	atacante = quien

func _physics_process(delta: float) -> void:
	# La espora muere sola al cumplir VIDA_ESPORA, aunque nunca impacte.
	_tiempo_vida += delta
	if expira(_tiempo_vida):
		queue_free()
		return
	global_position += _direccion * GameConfig.VELOCIDAD_ESPORA * delta

func _on_body_entered(body: Node3D) -> void:
	if _impactado:
		return
	# Solo reacciona a cuerpos que sepan recibir impactos (NPC).
	if not body.has_method("recibir_impacto"):
		return
	_impactado = true
	body.recibir_impacto(tamanio_atacante, atacante)
	queue_free()

# Un solo camino para disparar: instanciar, fijar a quien impacta, ubicar y
# configurar. Lo usan el jugador y el NPC; la mascara evita autogolpe y fuego amigo.
static func disparar(
	escena: PackedScene,
	contenedor: Node,
	origen: Vector3,
	direccion: Vector3,
	tamanio_atacante: float,
	atacante: Node3D,
	mascara: int
) -> Area3D:
	if escena == null or contenedor == null:
		return null
	var espora: Area3D = escena.instantiate() as Area3D
	if espora == null:
		return null
	# Antes de entrar al arbol, para que no detecte cuerpos con la mascara vieja.
	espora.collision_mask = mascara
	contenedor.add_child(espora)
	espora.global_position = origen
	if espora.has_method("configurar"):
		espora.configurar(direccion, tamanio_atacante, atacante)
	return espora

# Deja la direccion en el plano XZ y normalizada: sin apuntado vertical.
static func direccion_horizontal(direccion: Vector3) -> Vector3:
	var plana: Vector3 = Vector3(direccion.x, 0.0, direccion.z)
	if plana.length_squared() == 0.0:
		return Vector3.ZERO
	return plana.normalized()

# Regla pura de expiracion, testeable sin nodo.
static func expira(tiempo_vida: float) -> bool:
	return tiempo_vida >= GameConfig.VIDA_ESPORA
