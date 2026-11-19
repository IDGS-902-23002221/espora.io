extends Node3D

const EscudoScript: GDScript = preload("res://entities/pickup/escudo.gd")
const VelocidadScript: GDScript = preload("res://entities/pickup/velocidad.gd")

var _temporizador: float = 0.0
var _espera: float = 0.0
var _escudo_activo: bool = false
var _temporizador_velocidad: float = 0.0
var _espera_velocidad: float = 0.0
var _velocidad_activa: bool = false

func _ready() -> void:
	_espera = _siguiente_espera()
	_espera_velocidad = _siguiente_espera_velocidad()

func _process(delta: float) -> void:
	_actualizar_escudo(delta)
	_actualizar_velocidad(delta)

func _siguiente_espera() -> float:
	return randf_range(GameConfig.INTERVALO_ESPORA_ESCUDO_MIN, GameConfig.INTERVALO_ESPORA_ESCUDO_MAX)

func _siguiente_espera_velocidad() -> float:
	return randf_range(GameConfig.INTERVALO_ESPORA_VELOZ_MIN, GameConfig.INTERVALO_ESPORA_VELOZ_MAX)

func _actualizar_escudo(delta: float) -> void:
	if _escudo_activo:
		return
	_temporizador += delta
	if _temporizador < _espera:
		return
	_temporizador = 0.0
	_crear_escudo()

func _actualizar_velocidad(delta: float) -> void:
	if _velocidad_activa:
		return
	_temporizador_velocidad += delta
	if _temporizador_velocidad < _espera_velocidad:
		return
	_temporizador_velocidad = 0.0
	_crear_velocidad()

func _crear_escudo() -> void:
	var escudo: Area3D = EscudoScript.new() as Area3D
	escudo.name = "Escudo"
	escudo.position = _punto_aleatorio()
	escudo.tree_exited.connect(_on_escudo_salio)
	add_child(escudo)
	_escudo_activo = true

func _crear_velocidad() -> void:
	var velocidad: Area3D = VelocidadScript.new() as Area3D
	velocidad.name = "Velocidad"
	velocidad.position = _punto_aleatorio()
	velocidad.tree_exited.connect(_on_velocidad_salio)
	add_child(velocidad)
	_velocidad_activa = true

func _punto_aleatorio() -> Vector3:
	var angulo: float = randf() * TAU
	var radio: float = Bioma.radio_ponderado(randf(), randf())
	return Vector3(cos(angulo) * radio, 0.8, sin(angulo) * radio)

func _on_escudo_salio() -> void:
	_escudo_activo = false
	_temporizador = 0.0
	_espera = _siguiente_espera()

func _on_velocidad_salio() -> void:
	_velocidad_activa = false
	_temporizador_velocidad = 0.0
	_espera_velocidad = _siguiente_espera_velocidad()
