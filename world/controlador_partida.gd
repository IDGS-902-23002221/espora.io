extends Node3D

const EscenaNpc: PackedScene = preload("res://entities/npc/npc.tscn")
const TinteBiomasScript: GDScript = preload("res://world/tinte_biomas.gd")
# Misma altura que los NPC de la arena original.
const ALTURA_APARICION: float = 0.1
# Tope de reintentos al buscar un punto lejos del jugador.
const MAX_INTENTOS_APARICION: int = 32

@export var jugador: Node3D
@export var pantalla_resultado: CanvasLayer

# Autoload por ruta: `--check-only` valida el script sin cargar autoloads.
var _game_manager: Node
var _fin_mostrado: bool = false

func _ready() -> void:
	_instalar_tinte_biomas()
	_game_manager = get_node_or_null("/root/GameManager")
	if pantalla_resultado == null:
		pantalla_resultado = get_node_or_null("../PantallaResultado") as CanvasLayer
	if _game_manager != null:
		_game_manager.call("iniciar_partida")
	_conectar_eventos()
	_generar_horda()

func _instalar_tinte_biomas() -> void:
	var tinte: Node3D = TinteBiomasScript.new() as Node3D
	tinte.name = "TinteBiomas"
	add_child(tinte)

func _conectar_eventos() -> void:
	if jugador != null:
		jugador.connect("nutriente_consumido", _on_nutriente_consumido)
		jugador.connect("absorcion_realizada", _on_absorcion_realizada)
		jugador.connect("absorbido", _on_jugador_absorbido)
	if _game_manager == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso != null:
		progreso.derrota.connect(_on_derrota)

func _process(delta: float) -> void:
	if _game_manager == null:
		return
	if not bool(_game_manager.call("esta_jugando")):
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso != null:
		progreso.avanzar_tiempo(delta)
	_atender_debug()
	var hordas: Hordas = _game_manager.get("hordas")
	_procesar_eventos(hordas.avanzar_tiempo(delta))

func _on_nutriente_consumido() -> void:
	if _game_manager == null or jugador == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso == null:
		return
	progreso.sumar_nutriente()
	progreso.registrar_tamanio(float(jugador.get("tamanio")))

func _on_absorcion_realizada(_tamanio_absorbido: float) -> void:
	if _game_manager == null or jugador == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso == null:
		return
	progreso.registrar_absorcion()
	progreso.registrar_tamanio(float(jugador.get("tamanio")))

func _on_jugador_absorbido() -> void:
	if _game_manager == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso != null:
		progreso.perder_intento()

func _on_derrota() -> void:
	if _game_manager != null:
		_game_manager.call("terminar_partida", false)
	_mostrar_resultado(false)

func _mostrar_resultado(es_victoria: bool) -> void:
	if _fin_mostrado:
		return
	_fin_mostrado = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if pantalla_resultado == null or _game_manager == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	pantalla_resultado.call("mostrar", es_victoria, progreso)

func _atender_debug() -> void:
	if not OS.is_debug_build():
		return
	if not Input.is_action_just_pressed("debug_saltar_horda"):
		return
	var hordas: Hordas = _game_manager.get("hordas")
	_procesar_eventos(hordas.saltar_horda())

func _procesar_eventos(eventos: Array) -> void:
	for evento in eventos:
		var tipo: int = int(evento)
		if tipo == Hordas.Evento.INICIO_HORDA:
			_generar_horda()
		elif tipo == Hordas.Evento.FIN_HORDA:
			if _game_manager != null:
				var progreso: Puntaje = _game_manager.get("progreso")
				if progreso != null:
					progreso.sumar_horda()
		elif tipo == Hordas.Evento.FIN_PARTIDA:
			if _game_manager != null:
				var progreso: Puntaje = _game_manager.get("progreso")
				if progreso != null:
					progreso.sumar_horda()
				_game_manager.call("terminar_partida", true)
			_mostrar_resultado(true)

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
	var punto: Vector3 = _punto_aparicion()
	var zona: int = Bioma.zona_para_radio(Vector2(punto.x, punto.z).length())
	var tamanio: float = Bioma.tamanio_npc(zona, multiplicador, randf())
	if Bioma.es_roamer(zona, randf()):
		tamanio = Bioma.tamanio_roamer(multiplicador)
	# Antes de entrar al arbol: el `_ready` del NPC usa tamanio_inicial.
	npc.set("jugador", jugador)
	npc.set("mostrar_estado", true)
	npc.set("tamanio_inicial", tamanio)
	npc.position = punto
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
