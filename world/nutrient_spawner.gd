extends Node3D

@export var escena_nutriente: PackedScene

var _temporizador: float = 0.0
var _activos: int = 0
var _temporizador_dorado: float = 0.0
var _espera_dorado: float = 0.0
var _dorado_activo: bool = false

func _ready() -> void:
	_espera_dorado = _siguiente_espera_dorado()

func _process(delta: float) -> void:
	if escena_nutriente == null:
		return
	_actualizar_dorado(delta)
	if _activos >= GameConfig.NUTRIENTES_ACTIVOS_MAX:
		return

	_temporizador += delta
	if _temporizador < GameConfig.INTERVALO_REAPARICION_NUTRIENTE:
		return
	_temporizador = 0.0
	_crear_nutriente()

func _siguiente_espera_dorado() -> float:
	return randf_range(GameConfig.INTERVALO_NUTRIENTE_DORADO_MIN, GameConfig.INTERVALO_NUTRIENTE_DORADO_MAX)

func _actualizar_dorado(delta: float) -> void:
	if _dorado_activo:
		return
	_temporizador_dorado += delta
	if _temporizador_dorado < _espera_dorado:
		return
	_temporizador_dorado = 0.0
	_crear_dorado()

func _crear_nutriente() -> void:
	var nutriente: Node3D = escena_nutriente.instantiate()
	var angulo: float = randf() * TAU
	var radio: float = Bioma.radio_ponderado(randf(), randf())
	nutriente.position = Vector3(cos(angulo) * radio, 0.0, sin(angulo) * radio)
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
	var angulo: float = randf() * TAU
	var radio: float = Bioma.radio_ponderado(randf(), randf())
	nutriente.position = Vector3(cos(angulo) * radio, 0.0, sin(angulo) * radio)
	nutriente.tree_exited.connect(_on_dorado_salio)
	add_child(nutriente)
	_dorado_activo = true

func _on_nutriente_salio() -> void:
	_activos -= 1

func _on_dorado_salio() -> void:
	_dorado_activo = false
	_temporizador_dorado = 0.0
	_espera_dorado = _siguiente_espera_dorado()
