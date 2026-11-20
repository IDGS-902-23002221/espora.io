extends Node3D

const EscenaNpc: PackedScene = preload("res://entities/npc/npc.tscn")
const TinteBiomasScript: GDScript = preload("res://world/tinte_biomas.gd")
const PowerupSpawnerScript: GDScript = preload("res://world/powerup_spawner.gd")
const MenuPrincipalScript: GDScript = preload("res://ui/menu_principal.gd")
const MenuSkinsScript: GDScript = preload("res://ui/menu_skins.gd")
const MenuPausaScript: GDScript = preload("res://ui/menu_pausa.gd")
const PantallaCargaScript: GDScript = preload("res://ui/pantalla_carga.gd")
# Misma altura que los NPC de la arena original.
const ALTURA_APARICION: float = 0.1
# Tope de reintentos al buscar un punto lejos del jugador.
const MAX_INTENTOS_APARICION: int = 32

@export var jugador: Node3D
@export var pantalla_resultado: CanvasLayer

# Autoload por ruta: `--check-only` valida el script sin cargar autoloads.
var _game_manager: Node
var _fin_mostrado: bool = false
var _menu_principal: CanvasLayer
var _menu_skins: CanvasLayer
var _menu_pausa: CanvasLayer
var _pantalla_carga: CanvasLayer
var _hud: CanvasLayer

func _ready() -> void:
	_instalar_tinte_biomas()
	_instalar_powerups()
	_instalar_menus()
	_game_manager = get_node_or_null("/root/GameManager")
	var arena: Node = get_parent()
	if arena != null:
		_hud = arena.get_node_or_null("HUD") as CanvasLayer
	if pantalla_resultado == null:
		pantalla_resultado = get_node_or_null("../PantallaResultado") as CanvasLayer
	_conectar_eventos()
	if _game_manager != null and bool(_game_manager.call("esta_jugando")):
		_generar_horda()
	else:
		_mostrar_menu()

func _instalar_tinte_biomas() -> void:
	var tinte: Node3D = TinteBiomasScript.new() as Node3D
	tinte.name = "TinteBiomas"
	add_child(tinte)

func _instalar_powerups() -> void:
	var powerups: Node3D = PowerupSpawnerScript.new() as Node3D
	powerups.name = "Powerups"
	add_child(powerups)

func _instalar_menus() -> void:
	_menu_principal = MenuPrincipalScript.new() as CanvasLayer
	add_child(_menu_principal)
	_menu_principal.connect("iniciar", _on_menu_iniciar)
	_menu_principal.connect("skins", _mostrar_skins)
	_menu_principal.visible = false

	_menu_skins = MenuSkinsScript.new() as CanvasLayer
	add_child(_menu_skins)
	_menu_skins.connect("seleccionada", _on_skin_seleccionada)
	_menu_skins.connect("volver", _volver_al_menu)
	_menu_skins.visible = false

	_menu_pausa = MenuPausaScript.new() as CanvasLayer
	add_child(_menu_pausa)
	_menu_pausa.connect("reanudar", _reanudar)
	_menu_pausa.connect("abandonar", _abandonar)
	_menu_pausa.visible = false

	_pantalla_carga = PantallaCargaScript.new() as CanvasLayer
	add_child(_pantalla_carga)
	_pantalla_carga.connect("terminada", _on_carga_terminada)
	_pantalla_carga.visible = false

func _mostrar_menu() -> void:
	if _menu_principal == null:
		return
	_menu_principal.visible = true
	_menu_skins.visible = false
	_menu_pausa.visible = false
	_pantalla_carga.visible = false
	_ocultar_hud()
	get_tree().paused = true
	_liberar_mouse()

func _mostrar_skins() -> void:
	if _menu_principal != null:
		_menu_principal.visible = false
	if _menu_skins == null:
		return
	_menu_skins.visible = true
	_menu_skins.call("marcar_actual", _skin_actual())

func _volver_al_menu() -> void:
	if _menu_skins != null:
		_menu_skins.visible = false
	if _menu_principal != null:
		_menu_principal.visible = true

func _on_skin_seleccionada(nombre: String) -> void:
	if _game_manager != null:
		_game_manager.set("skin_jugador", nombre)
	if jugador != null and jugador.has_method("aplicar_skin"):
		jugador.call("aplicar_skin", nombre)
	if _menu_skins != null:
		_menu_skins.call("marcar_actual", nombre)

func _skin_actual() -> String:
	if _game_manager != null and _game_manager.get("skin_jugador") != null:
		return str(_game_manager.get("skin_jugador"))
	return "clasico"

func _on_menu_iniciar() -> void:
	if _menu_principal != null:
		_menu_principal.visible = false
	if _pantalla_carga != null:
		_pantalla_carga.visible = true
	_ocultar_hud()
	if _game_manager != null:
		_game_manager.call("iniciar_partida")
	_generar_horda()
	if _pantalla_carga != null:
		_pantalla_carga.call("iniciar", 0.8)
	else:
		get_tree().paused = false
		_recapturar_mouse()

func _on_carga_terminada() -> void:
	if _pantalla_carga != null:
		_pantalla_carga.visible = false
	_mostrar_hud()
	get_tree().paused = false
	_recapturar_mouse()

func _pausar() -> void:
	if _menu_pausa == null or _menu_pausa.visible:
		return
	if _game_manager != null:
		_game_manager.call("pausar")
	_menu_pausa.visible = true
	_ocultar_hud()
	get_tree().paused = true
	_liberar_mouse()

func _reanudar() -> void:
	if _menu_pausa != null:
		_menu_pausa.visible = false
	_mostrar_hud()
	get_tree().paused = false
	if _game_manager != null:
		_game_manager.call("reanudar")
	_recapturar_mouse()

func _abandonar() -> void:
	if _menu_pausa != null:
		_menu_pausa.visible = false
	_ocultar_hud()
	get_tree().paused = false
	if _game_manager != null:
		_game_manager.call("reiniciar")
	get_tree().reload_current_scene()

func _recapturar_mouse() -> void:
	if jugador != null:
		var camara: Node = jugador.get_node_or_null("SpringArm3D")
		if camara != null and camara.has_method("recapturar_mouse"):
			camara.call("recapturar_mouse")
			return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _liberar_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ocultar_hud() -> void:
	if _hud != null:
		_hud.visible = false

func _mostrar_hud() -> void:
	if _hud != null:
		_hud.visible = true

func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("pausa"):
		return
	if _game_manager == null or not bool(_game_manager.call("esta_jugando")):
		return
	_pausar()

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
	_ocultar_hud()
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

# Los NPC son los unicos CharacterBody3D hijos del controlador; el tinte,
# powerups y menus no deben contar como vivos.
func _contar_npcs() -> int:
	var total: int = 0
	for hijo in get_children():
		if hijo is CharacterBody3D:
			total += 1
	return total

# Top-up: conserva los NPC vivos (incluidos los que estan en cooldown) y agrega
# solo la diferencia hasta el objetivo de la horda, con el tope absoluto.
func _generar_horda() -> void:
	if _game_manager == null:
		return
	var config: Dictionary = _game_manager.call("configuracion_horda")
	var objetivo: int = int(config["npc_por_horda"])
	var vivos: int = _contar_npcs()
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
	# Antes de entrar al arbol: el `_ready` del NPC usa tamanio_inicial y zona.
	npc.set("jugador", jugador)
	npc.set("mostrar_estado", true)
	npc.set("tamanio_inicial", tamanio)
	npc.set("zona", zona)
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
