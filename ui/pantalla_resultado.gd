extends CanvasLayer

@export var etiqueta_titulo: Label
@export var etiqueta_subtitulo: Label
@export var etiqueta_puntaje: Label
@export var etiqueta_absorbidos: Label
@export var etiqueta_tamanio: Label
@export var etiqueta_tiempo: Label
@export var boton_reiniciar: Button

func _ready() -> void:
	# Sigue respondiendo con el arbol pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resolver_nodos()
	if boton_reiniciar != null:
		boton_reiniciar.pressed.connect(_on_reiniciar)
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
		boton_reiniciar.text = datos["boton"]
	visible = true

func _asignar(etiqueta: Label, texto: String) -> void:
	if etiqueta != null:
		etiqueta.text = texto

func _on_reiniciar() -> void:
	get_tree().paused = false
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm != null:
		gm.call("reiniciar")
	get_tree().reload_current_scene()
