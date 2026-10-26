extends Node3D

@export var escena_nutriente: PackedScene

var _temporizador: float = 0.0
var _activos: int = 0

func _process(delta: float) -> void:
	if escena_nutriente == null:
		return
	if _activos >= GameConfig.NUTRIENTES_ACTIVOS_MAX:
		return

	_temporizador += delta
	if _temporizador < GameConfig.INTERVALO_REAPARICION_NUTRIENTE:
		return
	_temporizador = 0.0
	_crear_nutriente()

func _crear_nutriente() -> void:
	var nutriente: Node3D = escena_nutriente.instantiate()
	var angulo: float = randf() * TAU
	var radio: float = GameConfig.RADIO_MAPA * sqrt(randf())
	nutriente.position = Vector3(cos(angulo) * radio, 0.0, sin(angulo) * radio)
	nutriente.tree_exited.connect(_on_nutriente_salio)
	add_child(nutriente)
	_activos += 1

func _on_nutriente_salio() -> void:
	_activos -= 1
