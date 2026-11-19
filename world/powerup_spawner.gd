extends Node3D

const EscudoScript: GDScript = preload("res://entities/pickup/escudo.gd")

var _temporizador: float = 0.0
var _espera: float = 0.0
var _escudo_activo: bool = false

func _ready() -> void:
	_espera = _siguiente_espera()

func _process(delta: float) -> void:
	if _escudo_activo:
		return
	_temporizador += delta
	if _temporizador < _espera:
		return
	_temporizador = 0.0
	_crear_escudo()

func _siguiente_espera() -> float:
	return randf_range(GameConfig.INTERVALO_ESPORA_ESCUDO_MIN, GameConfig.INTERVALO_ESPORA_ESCUDO_MAX)

func _crear_escudo() -> void:
	var escudo: Area3D = EscudoScript.new() as Area3D
	escudo.name = "Escudo"
	escudo.position = _punto_aleatorio()
	escudo.tree_exited.connect(_on_escudo_salio)
	add_child(escudo)
	_escudo_activo = true

func _punto_aleatorio() -> Vector3:
	var angulo: float = randf() * TAU
	var radio: float = Bioma.radio_ponderado(randf(), randf())
	return Vector3(cos(angulo) * radio, 0.8, sin(angulo) * radio)

func _on_escudo_salio() -> void:
	_escudo_activo = false
	_temporizador = 0.0
	_espera = _siguiente_espera()
