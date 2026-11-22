extends CanvasLayer

const EstiloScript = preload("res://ui/estilo_ui.gd")

@export var etiqueta_titulo: Label
@export var etiqueta_subtitulo: Label
@export var etiqueta_puntaje: Label
@export var etiqueta_absorbidos: Label
@export var etiqueta_tamanio: Label
@export var etiqueta_tiempo: Label
@export var boton_reiniciar: Button

var _tween_entrada: Tween
var _nombre: LineEdit
var _boton_lobby: Button

func _ready() -> void:
	# Sigue respondiendo con el arbol pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resolver_nodos()
	if boton_reiniciar != null:
		boton_reiniciar.pressed.connect(_on_reiniciar)
	_aplicar_estilo()
	visible = false

# Si los @export no se asignaron, se resuelven por nombre.
func _resolver_nodos() -> void:
	if etiqueta_titulo == null:
		etiqueta_titulo = get_node_or_null("Centro/LabelTitulo") as Label
	if etiqueta_subtitulo == null:
		etiqueta_subtitulo = get_node_or_null("Centro/LabelSubtitulo") as Label
	if etiqueta_puntaje == null:
		etiqueta_puntaje = get_node_or_null("Centro/LabelPuntaje") as Label
	if etiqueta_absorbidos == null:
		etiqueta_absorbidos = get_node_or_null("Centro/LabelAbsorbidos") as Label
	if etiqueta_tamanio == null:
		etiqueta_tamanio = get_node_or_null("Centro/LabelTamanio") as Label
	if etiqueta_tiempo == null:
		etiqueta_tiempo = get_node_or_null("Centro/LabelTiempo") as Label
	if boton_reiniciar == null:
		boton_reiniciar = get_node_or_null("Centro/ButtonReiniciar") as Button

func _aplicar_estilo() -> void:
	# El resultado nace de una escena: se estiliza por codigo sin tocar .tscn.
	var fondo: ColorRect = get_node_or_null("Fondo") as ColorRect
	if fondo != null:
		fondo.color = Color(0.008, 0.025, 0.018, 0.80)
	var adorno: Control = EstiloScript.adorno_bosque()
	add_child(adorno)
	adorno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(adorno, 1)
	_crear_panel()
	if etiqueta_titulo != null:
		EstiloScript.aplicar_titulo(etiqueta_titulo, 44)
	if etiqueta_subtitulo != null:
		EstiloScript.aplicar_texto(etiqueta_subtitulo, 22, EstiloScript.TEXTO_TENUE)
	for etiqueta in [etiqueta_puntaje, etiqueta_absorbidos, etiqueta_tamanio, etiqueta_tiempo]:
		if etiqueta != null:
			EstiloScript.aplicar_texto(etiqueta as Label, 20, EstiloScript.TEXTO)
	if boton_reiniciar != null:
		EstiloScript.aplicar_boton(boton_reiniciar, false)

# Envuelve los datos en un panel con fondo, como el resto de menus.
func _crear_panel() -> void:
	var centro_viejo: VBoxContainer = get_node_or_null("Centro") as VBoxContainer
	if centro_viejo == null:
		return
	var centro: CenterContainer = CenterContainer.new()
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "PanelResultado"
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	panel.add_theme_stylebox_override("panel", EstiloScript.panel())
	centro.add_child(panel)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override("separation", 12)
	panel.add_child(caja)
	for hijo in centro_viejo.get_children():
		centro_viejo.remove_child(hijo)
		caja.add_child(hijo)
	centro_viejo.visible = false

	_nombre = LineEdit.new()
	_nombre.name = "NombreJugador"
	_nombre.placeholder_text = "Tu nombre"
	_nombre.max_length = 20
	_nombre.custom_minimum_size = Vector2(320.0, 42.0)
	_nombre.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_nombre.add_theme_font_override("font", EstiloScript.fuente(400))
	_nombre.add_theme_font_size_override("font_size", 20)
	_nombre.add_theme_color_override("font_color", EstiloScript.TEXTO)
	_nombre.add_theme_color_override("caret_color", EstiloScript.ACENTO)
	_nombre.text_changed.connect(_on_nombre_cambiado)
	caja.add_child(_nombre)
	# El nombre va antes del boton de jugar de nuevo.
	caja.move_child(_nombre, maxi(0, caja.get_child_count() - 2))

	_boton_lobby = Button.new()
	_boton_lobby.name = "BotonLobby"
	_boton_lobby.text = "Volver al lobby"
	_boton_lobby.custom_minimum_size = Vector2(320.0, 52.0)
	_boton_lobby.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	EstiloScript.aplicar_boton(_boton_lobby, false)
	_boton_lobby.pressed.connect(_on_volver_lobby)
	caja.add_child(_boton_lobby)

func mostrar(victoria: bool, progreso: Puntaje) -> void:
	var datos: Dictionary = ResultadoPartida.textos(
		victoria, progreso.puntos, progreso.absorbidos,
		progreso.tamanio_maximo, progreso.tiempo
	)
	var lineas: Array = datos["lineas"]
	_asignar(etiqueta_titulo, datos["titulo"])
	_asignar(etiqueta_subtitulo, datos["subtitulo"])
	_asignar(etiqueta_puntaje, lineas[0])
	_asignar(etiqueta_absorbidos, lineas[1])
	_asignar(etiqueta_tamanio, lineas[2])
	_asignar(etiqueta_tiempo, lineas[3])
	if boton_reiniciar != null:
		boton_reiniciar.text = "Jugar de nuevo"
	if _nombre != null:
		var gm: Node = get_node_or_null("/root/GameManager")
		if gm != null:
			_nombre.text = str(gm.get("nombre_jugador"))
	visible = true
	_animar_entrada()

func _animar_entrada() -> void:
	if _tween_entrada != null and _tween_entrada.is_valid():
		_tween_entrada.kill()
	var controles: Array[Control] = [
		etiqueta_titulo, etiqueta_subtitulo, etiqueta_puntaje,
		etiqueta_absorbidos, etiqueta_tamanio, etiqueta_tiempo,
		_nombre, boton_reiniciar, _boton_lobby,
	]
	for control in controles:
		if control == null:
			continue
		var modulacion: Color = control.modulate
		modulacion.a = 0.0
		control.modulate = modulacion
	_tween_entrada = create_tween()
	_tween_entrada.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween_entrada.set_parallel(true)
	var retraso: float = 0.0
	for control in controles:
		if control == null:
			continue
		_tween_entrada.tween_property(control, "modulate:a", 1.0, 0.45).set_delay(retraso)
		retraso += 0.10

func _asignar(etiqueta: Label, texto: String) -> void:
	if etiqueta != null:
		etiqueta.text = texto

func _on_nombre_cambiado(texto: String) -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm == null:
		return
	var limpio: String = texto.strip_edges().left(20)
	gm.set("nombre_jugador", limpio if not limpio.is_empty() else "Jugador")

func _on_reiniciar() -> void:
	get_tree().paused = false
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.call("reiniciar")
		gm.call("iniciar_partida")
	get_tree().reload_current_scene()

func _on_volver_lobby() -> void:
	get_tree().paused = false
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.call("reiniciar")
	# Sin iniciar_partida: al recargar, el controlador muestra el lobby.
	get_tree().reload_current_scene()
