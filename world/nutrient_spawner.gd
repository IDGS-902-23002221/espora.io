extends Node3D

const EscudoScript: GDScript = preload("res://entities/pickup/escudo.gd")
const VelocidadScript: GDScript = preload("res://entities/pickup/velocidad.gd")

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

func _process(delta: float) -> void:
	if escena_nutriente == null:
		return
	_tiempo_juego += delta
	_temporizador += delta
	if _temporizador < GameConfig.INTERVALO_REAPARICION_NUTRIENTE:
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
		if not opciones.is_empty():
			_total += 1
			_especiales += 1
			match opciones[randi() % opciones.size()]:
				0:
					_crear_dorado()
				1:
					_crear_escudo()
				_:
					_crear_velocidad()
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
	nutriente.scale = Vector3.ONE * 1.35
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
