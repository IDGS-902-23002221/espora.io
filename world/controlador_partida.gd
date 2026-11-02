extends Node3D

const EscenaNpc: PackedScene = preload("res://entities/npc/npc.tscn")
# Misma altura que los NPC de la arena original.
const ALTURA_APARICION: float = 0.1
# Tope de reintentos al buscar un punto lejos del jugador.
const MAX_INTENTOS_APARICION: int = 32

@export var jugador: Node3D

# Autoload por ruta: `--check-only` valida el script sin cargar autoloads.
var _game_manager: Node

func _ready() -> void:
	_game_manager = get_node_or_null("/root/GameManager")
	if _game_manager != null:
		_game_manager.call("iniciar_partida")
	_generar_horda()

func _process(delta: float) -> void:
	if _game_manager == null:
		return
	if not bool(_game_manager.call("esta_jugando")):
		return
	_atender_debug()
	var hordas: Hordas = _game_manager.get("hordas")
	_procesar_eventos(hordas.avanzar_tiempo(delta))

func _atender_debug() -> void:
	if not OS.is_debug_build():
		return
	if not Input.is_action_just_pressed("debug_saltar_horda"):
		return
	var hordas: Hordas = _game_manager.get("hordas")
	_procesar_eventos(hordas.saltar_horda())

func _procesar_eventos(eventos: Array) -> void:
	for evento in eventos:
		if int(evento) == Hordas.Evento.INICIO_HORDA:
			_generar_horda()

# Top-up: conserva los NPC vivos (incluidos los que estan en cooldown) y agrega
# solo la diferencia hasta el objetivo de la horda, con el tope absoluto.
func _generar_horda() -> void:
	if _game_manager == null:
		return
	var config: Dictionary = _game_manager.call("configuracion_horda")
	var objetivo: int = int(config["npc_por_horda"])
	var vivos: int = get_child_count()
	var faltan: int = objetivo - vivos
	if faltan <= 0:
		return
	faltan = mini(faltan, GameConfig.NPC_MAX_ABSOLUTO - vivos)
	var multiplicador: float = float(config["mult_tamanio_aparicion"])
	for i in faltan:
		_crear_npc(multiplicador)

func _crear_npc(multiplicador: float) -> void:
	var npc: Node3D = EscenaNpc.instantiate() as Node3D
	if npc == null:
		return
	# Antes de entrar al arbol: el `_ready` del NPC usa tamanio_inicial.
	npc.set("jugador", jugador)
	npc.set("mostrar_estado", true)
	npc.set("tamanio_inicial", Hordas.tamanio_aparicion(multiplicador, randf()))
	npc.position = _punto_aparicion()
	add_child(npc)

# Distribucion uniforme en el circulo, rechazando puntos cerca del jugador.
func _punto_aparicion() -> Vector3:
	var punto: Vector3 = Vector3.ZERO
	for i in MAX_INTENTOS_APARICION:
		var angulo: float = randf() * TAU
		var radio: float = GameConfig.RADIO_MAPA * sqrt(randf())
		punto = Vector3(cos(angulo) * radio, ALTURA_APARICION, sin(angulo) * radio)
		if jugador == null:
			return punto
		var distancia: float = Vector2(
			punto.x - jugador.global_position.x,
			punto.z - jugador.global_position.z
		).length()
		if distancia >= GameConfig.DISTANCIA_MIN_APARICION:
			return punto
	# Si no encontro uno valido, usa el ultimo (evita bucle infinito).
	return punto
