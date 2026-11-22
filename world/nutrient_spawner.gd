extends Node3D

const EscudoScript: GDScript = preload("res://entities/pickup/escudo.gd")
const VelocidadScript: GDScript = preload("res://entities/pickup/velocidad.gd")
const CuraScript: GDScript = preload("res://entities/pickup/cura.gd")
const RaizScript: GDScript = preload("res://entities/pickup/raiz.gd")
const InvisibilidadScript: GDScript = preload("res://entities/pickup/invisibilidad.gd")
const AuraScript = preload("res://core/aura.gd")

# Despues de este tiempo empiezan a mezclarse las especiales.
const RETRASO_ESPECIALES: float = 50.0
# 40 % azules / 60 % especiales sobre el total de apariciones.
const PROPORCION_ESPECIALES: float = 0.6

@export var escena_nutriente: PackedScene

var _temporizador: float = 0.0
var _activos: int = 0
var _tiempo_juego: float = 0.0
var _total: int = 0
var _especiales: int = 0
var _dorado_activo: bool = false
var _escudo_activo: bool = false
var _velocidad_activa: bool = false
var _cura_activa: bool = false
var _raiz_activa: bool = false
var _invisibilidad_activa: bool = false

func _ready() -> void:
	# Arranque con nutrientes suficientes para que no cueste crecer.
	if escena_nutriente == null:
		return
	for i in 12:
		_total += 1
		_crear_nutriente()

func _process(delta: float) -> void:
	if escena_nutriente == null:
		return
	_tiempo_juego += delta
	_temporizador += delta
	var intervalo: float = GameConfig.INTERVALO_REAPARICION_NUTRIENTE
	if _tiempo_juego < GameConfig.PRESION_HORDA_RETRASO_INICIAL:
		intervalo = 0.45
	if _temporizador < intervalo:
		return
	_temporizador = 0.0
	_crear_siguiente()

# Decide azul o especial manteniendo la proporcion pedida.
func _crear_siguiente() -> void:
	# Los especiales pueden salir aunque el tope de azules este lleno.
	if toca_especial(_tiempo_juego, _total, _especiales):
		var opciones: Array[int] = []
		if not _dorado_activo:
			opciones.append(0)
		if not _escudo_activo:
			opciones.append(1)
		if not _velocidad_activa:
			opciones.append(2)
		if not _cura_activa and _puede_curar():
			opciones.append(3)
		if not _raiz_activa:
			opciones.append(4)
		if not _invisibilidad_activa:
			opciones.append(5)
		if not opciones.is_empty():
			_total += 1
			_especiales += 1
			match opciones[randi() % opciones.size()]:
				0:
					_crear_dorado()
				1:
					_crear_escudo()
				2:
					_crear_velocidad()
				3:
					_crear_cura()
				4:
					_crear_raiz()
				_:
					_crear_invisibilidad()
			return
	if _activos >= GameConfig.NUTRIENTES_ACTIVOS_MAX:
		return
	_total += 1
	_crear_nutriente()

# Regla pura: antes de 50 s solo azules; despues busca 40 % especiales.
static func toca_especial(
	tiempo: float, total_previo: int, especiales: int,
	retraso: float = RETRASO_ESPECIALES, proporcion: float = PROPORCION_ESPECIALES
) -> bool:
	if tiempo < retraso:
		return false
	if total_previo <= 0:
		return true
	return float(especiales) / float(total_previo) < proporcion

func _crear_nutriente() -> void:
	var nutriente: Node3D = escena_nutriente.instantiate()
	nutriente.scale = Vector3.ONE * 1.15
	nutriente.position = _punto_aleatorio(0.0)
	nutriente.tree_exited.connect(_on_nutriente_salio)
	add_child(nutriente)
	_activos += 1

func _crear_dorado() -> void:
	var nutriente: Node3D = escena_nutriente.instantiate()
	nutriente.set("multiplicador_crecimiento", GameConfig.MULT_NUTRIENTE_DORADO)
	var malla: MeshInstance3D = nutriente.get_node("MeshInstance3D") as MeshInstance3D
	if malla != null:
		var base: StandardMaterial3D = malla.material_override as StandardMaterial3D
		if base != null:
			var material: StandardMaterial3D = base.duplicate() as StandardMaterial3D
			material.albedo_color = Color(1.0, 0.78, 0.10)
			material.emission = Color(1.0, 0.55, 0.0)
			malla.material_override = material
	nutriente.scale = Vector3.ONE * 1.85
	var aura: MeshInstance3D = AuraScript.crear(nutriente, Color(1.0, 0.78, 0.2), 0.85, 1.4)
	aura.position = Vector3(0.0, 0.4, 0.0)
	nutriente.position = _punto_aleatorio(0.0)
	nutriente.tree_exited.connect(_on_dorado_salio)
	add_child(nutriente)
	_dorado_activo = true

func _crear_escudo() -> void:
	var escudo: Area3D = EscudoScript.new() as Area3D
	escudo.name = "Escudo"
	escudo.position = _punto_aleatorio(0.8)
	escudo.tree_exited.connect(_on_escudo_salio)
	add_child(escudo)
	_escudo_activo = true

func _crear_velocidad() -> void:
	var velocidad: Area3D = VelocidadScript.new() as Area3D
	velocidad.name = "Velocidad"
	velocidad.position = _punto_aleatorio(0.8)
	velocidad.tree_exited.connect(_on_velocidad_salio)
	add_child(velocidad)
	_velocidad_activa = true

func _puede_curar() -> bool:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm == null:
		return false
	var progreso: Puntaje = gm.get("progreso")
	return progreso != null and progreso.intentos < GameConfig.INTENTOS_INICIALES

func _crear_cura() -> void:
	var cura: Area3D = CuraScript.new() as Area3D
	cura.name = "Cura"
	cura.position = _punto_aleatorio(0.8)
	cura.tree_exited.connect(_on_cura_salio)
	add_child(cura)
	_cura_activa = true

func _crear_raiz() -> void:
	var raiz: Area3D = RaizScript.new() as Area3D
	raiz.name = "Raiz"
	raiz.position = _punto_aleatorio(0.8)
	raiz.tree_exited.connect(_on_raiz_salio)
	add_child(raiz)
	_raiz_activa = true

func _crear_invisibilidad() -> void:
	var invisibilidad: Area3D = InvisibilidadScript.new() as Area3D
	invisibilidad.name = "Invisibilidad"
	invisibilidad.position = _punto_aleatorio(0.8)
	invisibilidad.tree_exited.connect(_on_invisibilidad_salio)
	add_child(invisibilidad)
	_invisibilidad_activa = true

func _punto_aleatorio(altura: float) -> Vector3:
	var angulo: float = randf() * TAU
	var radio: float = Bioma.radio_ponderado(randf(), randf())
	return Vector3(cos(angulo) * radio, altura, sin(angulo) * radio)

func _on_nutriente_salio() -> void:
	_activos -= 1

func _on_dorado_salio() -> void:
	_dorado_activo = false

func _on_escudo_salio() -> void:
	_escudo_activo = false

func _on_velocidad_salio() -> void:
	_velocidad_activa = false

func _on_cura_salio() -> void:
	_cura_activa = false

func _on_raiz_salio() -> void:
	_raiz_activa = false

func _on_invisibilidad_salio() -> void:
	_invisibilidad_activa = false
