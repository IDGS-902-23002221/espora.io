extends CanvasLayer

signal seleccionada(nombre: String)
signal volver

const EstiloScript = preload("res://ui/estilo_ui.gd")
const EspeciesScript = preload("res://core/especies.gd")
const CAPA: int = 31

var _etiqueta_nombre: Label
var _etiqueta_descripcion: Label
var _etiqueta_indice: Label
var _modelo_previa: Node3D
var _skins: Array[String] = []
var _indice: int = 0

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = CAPA

func _ready() -> void:
	visible = false
	_skins = EspeciesScript.skins_disponibles()

	var raiz: Control = Control.new()
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fondo: TextureRect = EstiloScript.fondo_gradiente()
	raiz.add_child(fondo)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var glow: TextureRect = EstiloScript.glow_radial()
	raiz.add_child(glow)
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var adorno: Control = EstiloScript.adorno_bosque()
	raiz.add_child(adorno)
	adorno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro: CenterContainer = CenterContainer.new()
	raiz.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", EstiloScript.panel())
	centro.add_child(panel)

	var caja: VBoxContainer = VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	panel.add_child(caja)

	var titulo: Label = Label.new()
	titulo.text = "Skins"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_titulo(titulo, 48)
	caja.add_child(titulo)

	# Carrusel: flechas a los lados del preview, nombre y descripcion debajo.
	var fila: HBoxContainer = HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 12)
	caja.add_child(fila)

	var boton_anterior: Button = _boton_flecha("◀", "BotonAnterior")
	fila.add_child(boton_anterior)
	boton_anterior.pressed.connect(func() -> void: _cambiar(-1))

	var columna: VBoxContainer = VBoxContainer.new()
	columna.add_theme_constant_override("separation", 4)
	fila.add_child(columna)

	var contenedor: SubViewportContainer = SubViewportContainer.new()
	contenedor.custom_minimum_size = Vector2(420.0, 260.0)
	contenedor.stretch = true
	contenedor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columna.add_child(contenedor)

	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(420, 260)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	contenedor.add_child(viewport)

	var mundo: Node3D = Node3D.new()
	viewport.add_child(mundo)

	var camara: Camera3D = Camera3D.new()
	camara.fov = 55.0
	mundo.add_child(camara)
	camara.look_at_from_position(Vector3(0.0, 1.1, 2.8), Vector3(0.0, 0.85, 0.0), Vector3.UP)

	var luz: DirectionalLight3D = DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
	luz.light_energy = 1.3
	mundo.add_child(luz)

	var relleno: OmniLight3D = OmniLight3D.new()
	relleno.position = Vector3(0.0, 2.2, 2.2)
	relleno.omni_range = 8.0
	relleno.light_energy = 0.9
	mundo.add_child(relleno)

	_modelo_previa = Node3D.new()
	mundo.add_child(_modelo_previa)

	_etiqueta_nombre = Label.new()
	_etiqueta_nombre.name = "EtiquetaSkin"
	_etiqueta_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(_etiqueta_nombre, 26, EstiloScript.ACENTO, 600)
	columna.add_child(_etiqueta_nombre)

	_etiqueta_descripcion = Label.new()
	_etiqueta_descripcion.name = "EtiquetaDescripcion"
	_etiqueta_descripcion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(_etiqueta_descripcion, 16, EstiloScript.TEXTO_TENUE)
	columna.add_child(_etiqueta_descripcion)

	_etiqueta_indice = Label.new()
	_etiqueta_indice.name = "EtiquetaIndice"
	_etiqueta_indice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	EstiloScript.aplicar_texto(_etiqueta_indice, 14, EstiloScript.TEXTO_TENUE)
	columna.add_child(_etiqueta_indice)

	var boton_siguiente: Button = _boton_flecha("▶", "BotonSiguiente")
	fila.add_child(boton_siguiente)
	boton_siguiente.pressed.connect(func() -> void: _cambiar(1))

	var boton_volver: Button = _boton("Volver", "BotonVolver")
	boton_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(boton_volver)
	boton_volver.pressed.connect(func() -> void: volver.emit())

	marcar_actual("clasico")

func _boton(texto: String, nombre: String) -> Button:
	var boton: Button = Button.new()
	boton.text = texto
	boton.name = nombre
	boton.custom_minimum_size = Vector2(300.0, 50.0)
	EstiloScript.aplicar_boton(boton, false)
	return boton

func _boton_flecha(texto: String, nombre: String) -> Button:
	var boton: Button = _boton(texto, nombre)
	boton.custom_minimum_size = Vector2(54.0, 54.0)
	boton.add_theme_font_size_override("font_size", 26)
	boton.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return boton

func marcar_actual(nombre: String) -> void:
	var indice: int = _skins.find(nombre)
	if indice >= 0:
		_indice = indice
	_refrescar()

func _cambiar(paso: int) -> void:
	if _skins.is_empty():
		return
	var total: int = _skins.size()
	_indice = (_indice + paso) % total
	if _indice < 0:
		_indice += total
	_refrescar()
	seleccionada.emit(_skins[_indice])

func _refrescar() -> void:
	if _skins.is_empty():
		return
	var nombre: String = _skins[_indice]
	if _etiqueta_nombre != null:
		_etiqueta_nombre.text = _nombre_visible(nombre)
	if _etiqueta_descripcion != null:
		_etiqueta_descripcion.text = _descripcion(nombre)
	if _etiqueta_indice != null:
		_etiqueta_indice.text = "%d / %d" % [_indice + 1, _skins.size()]
	_actualizar_previa(nombre)

func _nombre_visible(nombre: String) -> String:
	match nombre:
		EspeciesScript.SKIN_LUMINARIA:
			return "Luminaria"
		EspeciesScript.SKIN_REY:
			return "Rey"
		_:
			return "Clásico"

func _descripcion(nombre: String) -> String:
	match nombre:
		EspeciesScript.SKIN_LUMINARIA:
			return "Mushnub Evolved con brillo cyan"
		EspeciesScript.SKIN_REY:
			return "Mushroom King con corona"
		_:
			return "El hongo de siempre"

func _actualizar_previa(nombre: String) -> void:
	if _modelo_previa == null:
		return
	for hijo in _modelo_previa.get_children():
		hijo.queue_free()
	var datos: Dictionary = EspeciesScript.colores_skin(nombre)
	var ruta: String = EspeciesScript.modelo_para_skin(nombre)
	if EspeciesScript.modelo_disponible(ruta):
		var escena: PackedScene = load(ruta) as PackedScene
		if escena != null:
			var modelo: Node3D = escena.instantiate() as Node3D
			_modelo_previa.add_child(modelo)
			EspeciesScript.normalizar_modelo(modelo)
			if bool(datos["emision"]):
				EspeciesScript.aplicar_emision_modelo(modelo, datos["sombrero"], float(datos["energia"]))
			EspeciesScript.reproducir_idle(modelo)
			return
	_modelo_previa.add_child(_modelo_fallback(datos))

func _modelo_fallback(datos: Dictionary) -> Node3D:
	var raiz: Node3D = Node3D.new()
	var cuerpo: MeshInstance3D = MeshInstance3D.new()
	var cilindro: CylinderMesh = CylinderMesh.new()
	cilindro.top_radius = 0.28
	cilindro.height = 0.9
	cilindro.radial_segments = 12
	cuerpo.mesh = cilindro
	cuerpo.position = Vector3(0.0, 0.45, 0.0)
	var material_cuerpo: StandardMaterial3D = StandardMaterial3D.new()
	material_cuerpo.albedo_color = datos["cuerpo"]
	cuerpo.material_override = material_cuerpo
	raiz.add_child(cuerpo)
	var sombrero: MeshInstance3D = MeshInstance3D.new()
	var esfera: SphereMesh = SphereMesh.new()
	esfera.radius = 0.6
	esfera.height = 0.8
	esfera.radial_segments = 12
	esfera.rings = 6
	sombrero.mesh = esfera
	sombrero.position = Vector3(0.0, 1.1, 0.0)
	var material_sombrero: StandardMaterial3D = StandardMaterial3D.new()
	material_sombrero.albedo_color = datos["sombrero"]
	if bool(datos["emision"]):
		material_sombrero.emission_enabled = true
		material_sombrero.emission = datos["sombrero"]
		material_sombrero.emission_energy_multiplier = float(datos["energia"])
	sombrero.material_override = material_sombrero
	raiz.add_child(sombrero)
	return raiz

func _process(delta: float) -> void:
	if not visible:
		return
	if _modelo_previa != null:
		_modelo_previa.rotation.y += delta * 0.6

func _unhandled_input(evento: InputEvent) -> void:
	if visible and evento.is_action_pressed("pausa"):
		volver.emit()
