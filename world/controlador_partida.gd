extends Node3D

const EscenaNpc: PackedScene = preload("res://entities/npc/npc.tscn")
const TinteBiomasScript: GDScript = preload("res://world/tinte_biomas.gd")
const DecoracionScript: GDScript = preload("res://world/decoracion.gd")
const MenuPrincipalScript: GDScript = preload("res://ui/menu_principal.gd")
const MenuSkinsScript: GDScript = preload("res://ui/menu_skins.gd")
const MenuPausaScript: GDScript = preload("res://ui/menu_pausa.gd")
const PantallaCargaScript: GDScript = preload("res://ui/pantalla_carga.gd")
const CinematicaScript: GDScript = preload("res://ui/cinematica.gd")
const CartelasScript: GDScript = preload("res://core/cartelas.gd")
const RankingVivoScript: GDScript = preload("res://ui/ranking_vivo.gd")
# Misma altura que los NPC de la arena original.
const ALTURA_APARICION: float = 0.1
# Tope de reintentos al buscar un punto lejos del jugador.
const MAX_INTENTOS_APARICION: int = 32

@export var jugador: Node3D
@export var pantalla_resultado: CanvasLayer

# Autoload por ruta: `--check-only` valida el script sin cargar autoloads.
var _game_manager: Node
var _fin_mostrado: bool = false
var _tiempo_horda: float = 0.0
var _oleadas: int = 0
var _menu_principal: CanvasLayer
var _menu_skins: CanvasLayer
var _menu_pausa: CanvasLayer
var _pantalla_carga: CanvasLayer
var _ranking: CanvasLayer
var _cinematica: CanvasLayer
var _accion_cinematica: Callable
var _hud: CanvasLayer

func _ready() -> void:
	_instalar_tinte_biomas()
	_instalar_textura_suelo()
	_instalar_fondo_galaxia()
	_instalar_decoracion()
	_instalar_menus()
	_instalar_ranking()
	_instalar_cinematica()
	_ajustar_rendimiento()
	_game_manager = get_node_or_null("/root/GameManager")
	var arena: Node = get_parent()
	if arena != null:
		_hud = arena.get_node_or_null("HUD") as CanvasLayer
	if pantalla_resultado == null:
		pantalla_resultado = get_node_or_null("../PantallaResultado") as CanvasLayer
	_conectar_eventos()
	if _game_manager != null and bool(_game_manager.call("esta_jugando")):
		_reiniciar_oleadas()
		_generar_horda()
		_mostrar_acto_i()
	elif _game_manager != null and not bool(_game_manager.get("apertura_mostrada")):
		_game_manager.call("marcar_apertura_mostrada")
		_mostrar_apertura()
	else:
		_mostrar_menu()

func _ajustar_rendimiento() -> void:
	var arena: Node = get_parent()
	if arena == null:
		return
	var luna: DirectionalLight3D = arena.get_node_or_null("LuzLuna") as DirectionalLight3D
	if luna != null:
		luna.directional_shadow_max_distance = 50.0
	var ambiente: WorldEnvironment = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if ambiente != null and ambiente.environment != null:
		ambiente.environment.fog_density = 0.002

func _instalar_tinte_biomas() -> void:
	var tinte: Node3D = TinteBiomasScript.new() as Node3D
	tinte.name = "TinteBiomas"
	add_child(tinte)

func _instalar_decoracion() -> void:
	var decoracion: Node3D = DecoracionScript.new() as Node3D
	decoracion.name = "Decoracion"
	add_child(decoracion)

# Piso con textura procedural de pasto; no necesita assets externos.
func _instalar_textura_suelo() -> void:
	var arena: Node = get_parent()
	if arena == null:
		return
	var malla: MeshInstance3D = arena.get_node_or_null("StaticBody3D/MeshInstance3D") as MeshInstance3D
	if malla == null:
		return
	var ruido: FastNoiseLite = FastNoiseLite.new()
	ruido.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ruido.frequency = 0.035
	ruido.fractal_octaves = 4
	var textura: NoiseTexture2D = NoiseTexture2D.new()
	textura.width = 256
	textura.height = 256
	textura.noise = ruido
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	ramp.colors = PackedColorArray([
		Color(0.055, 0.12, 0.065),
		Color(0.09, 0.20, 0.10),
		Color(0.16, 0.31, 0.16),
	])
	textura.color_ramp = ramp
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = textura
	material.albedo_color = Color(1.0, 1.0, 1.0)
	material.roughness = 1.0
	material.uv1_triplanar = false
	material.uv1_world_triplanar = false
	material.uv1_scale = Vector3(6.0, 6.0, 6.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	malla.material_override = material

# Cielo de galaxia procedural: una textura de ruido, sin assets externos.
func _instalar_fondo_galaxia() -> void:
	var arena: Node = get_parent()
	if arena == null:
		return
	var ambiente: WorldEnvironment = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if ambiente == null or ambiente.environment == null:
		return
	# Cielo simple de 3 colores: mucho mas barato que una textura panoramica.
	var material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	material.sky_top_color = Color(0.015, 0.02, 0.07)
	material.sky_horizon_color = Color(0.08, 0.06, 0.18)
	material.ground_bottom_color = Color(0.01, 0.02, 0.03)
	material.ground_horizon_color = Color(0.04, 0.07, 0.09)
	var cielo: Sky = Sky.new()
	cielo.sky_material = material
	var entorno: Environment = ambiente.environment
	entorno.background_mode = Environment.BG_SKY
	entorno.sky = cielo
	entorno.background_energy_multiplier = 0.8
	entorno.ambient_light_color = Color(0.13, 0.14, 0.28)

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

func _instalar_ranking() -> void:
	_ranking = RankingVivoScript.new() as CanvasLayer
	add_child(_ranking)
	# El jugador se pasa al crear; los NPC se leen del grupo "npcs" al refrescar.
	_ranking.call("configurar", jugador)
	_ranking.visible = false

func _instalar_cinematica() -> void:
	_cinematica = CinematicaScript.new() as CanvasLayer
	add_child(_cinematica)
	_cinematica.connect("terminada", _on_cinematica_terminada)
	_cinematica.visible = false

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
	_reiniciar_oleadas()
	_generar_horda()
	if _pantalla_carga != null:
		_pantalla_carga.call("iniciar", 0.8)
	else:
		get_tree().paused = false
		_recapturar_mouse()

func _on_carga_terminada() -> void:
	if _pantalla_carga != null:
		_pantalla_carga.visible = false
	_mostrar_acto_i()

func _mostrar_apertura() -> void:
	_mostrar_cinematica(CartelasScript.apertura(), _mostrar_menu)

func _mostrar_acto_i() -> void:
	_mostrar_cinematica(CartelasScript.acto_i(), _continuar_partida)

func _continuar_partida() -> void:
	_mostrar_hud()
	_anunciar_horda()
	get_tree().paused = false
	_recapturar_mouse()

func _mostrar_cinematica(escenas: Array, accion: Callable) -> void:
	if _cinematica == null:
		accion.call()
		return
	_accion_cinematica = accion
	_ocultar_hud()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_cinematica.visible = true
	_cinematica.call("mostrar", escenas)

func _on_cinematica_terminada() -> void:
	var accion: Callable = _accion_cinematica
	_accion_cinematica = Callable()
	if accion.is_valid():
		accion.call()

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
	if _ranking != null:
		_ranking.visible = false

func _mostrar_hud() -> void:
	if _hud != null:
		_hud.visible = true
	if _ranking != null:
		_ranking.visible = true

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
	_actualizar_oleadas(delta, hordas)

# Refuerzos a 1/3 y 2/3 de la horda para que no sea un reloj plano.
func _actualizar_oleadas(delta: float, hordas: Hordas) -> void:
	if hordas.en_pausa or hordas.terminada:
		return
	_tiempo_horda += delta
	var duracion: float = Hordas.duracion(hordas.indice)
	if duracion <= 0.0:
		return
	while _oleadas < 2 and _tiempo_horda >= duracion * float(_oleadas + 1) / 3.0:
		_oleadas += 1
		_reforzar_horda(2)

func _reforzar_horda(cantidad: int) -> void:
	if _game_manager == null:
		return
	var config: Dictionary = _game_manager.call("configuracion_horda")
	var vivos: int = _contar_npcs()
	var cupo: int = mini(cantidad, GameConfig.NPC_MAX_ABSOLUTO - vivos)
	if cupo <= 0:
		return
	var multiplicador: float = float(config["mult_tamanio_aparicion"])
	for i in cupo:
		_crear_npc(multiplicador)

func _reiniciar_oleadas() -> void:
	_tiempo_horda = 0.0
	_oleadas = 0

func _anunciar_horda() -> void:
	if _hud == null or _game_manager == null:
		return
	var config: Dictionary = _game_manager.call("configuracion_horda")
	if config.is_empty():
		return
	var indice: int = int(_game_manager.get("indice_horda"))
	var aviso: String = str(config.get("aviso", "La horda cambia"))
	_hud.call(
		"mostrar_anuncio_horda",
		"Horda %d/%d — %s" % [indice + 1, Hordas.total(), aviso],
		3.5
	)

func _on_nutriente_consumido() -> void:
	if _game_manager == null or jugador == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso == null:
		return
	progreso.sumar_nutriente()
	if float(jugador.get("tamanio")) >= _maximo_actual():
		progreso.sumar_excedente(GameConfig.PUNTOS_EXCEDENTE_NUTRIENTE)
	progreso.registrar_tamanio(float(jugador.get("tamanio")))

func _maximo_actual() -> float:
	if _game_manager != null and _game_manager.has_method("maximo_actual"):
		return float(_game_manager.call("maximo_actual"))
	return GameConfig.TAMANIO_MAXIMO

func _on_absorcion_realizada(_tamanio_absorbido: float) -> void:
	if _game_manager == null or jugador == null:
		return
	var progreso: Puntaje = _game_manager.get("progreso")
	if progreso == null:
		return
	progreso.registrar_absorcion()
	if float(jugador.get("tamanio")) >= _maximo_actual():
		progreso.sumar_excedente(GameConfig.PUNTOS_EXCEDENTE_ABSORCION)
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
	_mostrar_cinematica(
		CartelasScript.acto_iv(es_victoria),
		func() -> void: _mostrar_resultado_final(es_victoria)
	)

func _mostrar_resultado_final(es_victoria: bool) -> void:
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
			_reiniciar_oleadas()
			_generar_horda()
			_anunciar_horda()
		elif tipo == Hordas.Evento.FIN_HORDA:
			if _game_manager != null:
				var progreso: Puntaje = _game_manager.get("progreso")
				if progreso != null:
					progreso.sumar_horda()
					# Recompensa: recuperar una hoja si estas por debajo del maximo.
					progreso.recuperar_intento()
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
