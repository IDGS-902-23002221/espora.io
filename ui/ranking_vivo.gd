extends CanvasLayer

# Panel de ranking en vivo, arriba a la derecha durante la partida.
const RankingScript = preload("res://core/ranking.gd")
const EstiloScript = preload("res://ui/estilo_ui.gd")
const CAPA: int = 12
const INTERVALO: float = 0.4
const MAX_FILAS: int = 5

var _jugador: Node3D
var _filas: VBoxContainer
var _tiempo: float = 0.0

func _init() -> void:
	layer = CAPA

func _ready() -> void:
	# Solo corre mientras la partida esta activa; se oculta con el HUD.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_construir()
	visible = false
	_tiempo = INTERVALO

func configurar(jugador: Node3D) -> void:
	_jugador = jugador

func _process(delta: float) -> void:
	if not visible:
		return
	_tiempo += delta
	if _tiempo < INTERVALO:
		return
	_tiempo = 0.0
	_refrescar()

func _construir() -> void:
	var raiz: Control = Control.new()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Margen superior/derecho para separar el panel del borde.
	var margen: MarginContainer = MarginContainer.new()
	margen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margen.add_theme_constant_override("margin_top", 16)
	margen.add_theme_constant_override("margin_right", 16)
	raiz.add_child(margen)
	margen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var columna: VBoxContainer = VBoxContainer.new()
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margen.add_child(columna)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "PanelRanking"
	panel.custom_minimum_size = Vector2(300.0, 0.0)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel.add_theme_stylebox_override("panel", _estilo_panel())
	columna.add_child(panel)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.name = "CajaRanking"
	caja.add_theme_constant_override("separation", 4)
	panel.add_child(caja)

	var titulo: Label = Label.new()
	titulo.text = "RANKING"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", EstiloScript.fuente(700))
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(0.45, 1.0, 1.0))
	caja.add_child(titulo)

	var subtitulo: Label = Label.new()
	subtitulo.text = "tamanio - puntos"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_override("font", EstiloScript.fuente(400))
	subtitulo.add_theme_font_size_override("font_size", 11)
	subtitulo.add_theme_color_override("font_color", Color(0.55, 0.75, 0.8, 0.8))
	caja.add_child(subtitulo)

	_filas = VBoxContainer.new()
	_filas.name = "FilasRanking"
	_filas.add_theme_constant_override("separation", 2)
	caja.add_child(_filas)

func _estilo_panel() -> StyleBoxFlat:
	# Version compacta del panel general para no tapar la esquina jugable.
	var s: StyleBoxFlat = EstiloScript.panel()
	s.bg_color = Color(0.02, 0.05, 0.07, 0.88)
	s.border_color = Color(0.2, 0.8, 0.9, 0.35)
	s.content_margin_left = 14.0
	s.content_margin_right = 14.0
	s.content_margin_top = 10.0
	s.content_margin_bottom = 10.0
	s.corner_radius_top_left = 12
	s.corner_radius_top_right = 12
	s.corner_radius_bottom_left = 12
	s.corner_radius_bottom_right = 12
	s.shadow_size = 10
	return s

func _refrescar() -> void:
	var entradas: Array = []
	# El jugador compite con los NPC; si no existe, solo se listan NPC.
	if _jugador != null and is_instance_valid(_jugador):
		entradas.append(RankingScript.entrada("Tú", _tamanio_de(_jugador), true))
	for nodo in get_tree().get_nodes_in_group("npcs"):
		if nodo == null or not is_instance_valid(nodo):
			continue
		var nombre: String = "NPC"
		if nodo.has_method("nombre_actual"):
			nombre = str(nodo.call("nombre_actual"))
		entradas.append(RankingScript.entrada(nombre, _tamanio_de(nodo), false))
	mostrar_entradas(RankingScript.ordenar(entradas, MAX_FILAS))

func mostrar_entradas(entradas: Array) -> void:
	if _filas == null:
		return
	# Vaciar de inmediato: evita filas duplicadas si se refresca varias veces.
	for hijo in _filas.get_children():
		_filas.remove_child(hijo)
		hijo.queue_free()
	if entradas.is_empty():
		var vacio: Label = _etiqueta("Sin datos", Color(0.7, 0.8, 0.85), 0)
		vacio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_filas.add_child(vacio)
		return
	for indice in entradas.size():
		var datos: Dictionary = entradas[indice] as Dictionary
		_filas.add_child(_fila(indice, datos))

func _fila(indice: int, datos: Dictionary) -> HBoxContainer:
	var fila: HBoxContainer = HBoxContainer.new()
	fila.name = "FilaRanking%d" % (indice + 1)
	fila.add_theme_constant_override("separation", 6)
	var es_jugador: bool = bool(datos.get("es_jugador", false))
	var color: Color = Color(1.0, 0.86, 0.35) if es_jugador else Color(0.82, 0.95, 1.0)

	var puesto: Label = _etiqueta("%d." % (indice + 1), color, 22)
	fila.add_child(puesto)

	var nombre: Label = _etiqueta(_recortar(str(datos.get("nombre", "")), 12), color, 0)
	nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(nombre)

	var tamanio: Label = _etiqueta("%.1f" % float(datos.get("tamanio", 0.0)), color, 42)
	tamanio.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fila.add_child(tamanio)

	var puntos: Label = _etiqueta("%d" % int(datos.get("puntos", 0)), color, 46)
	puntos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fila.add_child(puntos)
	return fila

func _etiqueta(texto: String, color: Color, ancho: float) -> Label:
	var etiqueta: Label = Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_override("font", EstiloScript.fuente(600))
	etiqueta.add_theme_font_size_override("font_size", 15)
	etiqueta.add_theme_color_override("font_color", color)
	if ancho > 0.0:
		etiqueta.custom_minimum_size = Vector2(ancho, 0.0)
	return etiqueta

func _tamanio_de(nodo: Node) -> float:
	var valor: Variant = nodo.get("tamanio")
	if valor == null:
		return 0.0
	return float(valor)

static func _recortar(texto: String, maximo: int) -> String:
	var limpio: String = texto.strip_edges()
	if limpio.length() <= maximo:
		return limpio
	return limpio.left(maximo - 3) + "..."
