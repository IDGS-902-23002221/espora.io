class_name PuntosDano
extends RefCounted

signal puntos_cambiados(restantes: int)
signal absorbido

const EPSILON: float = 0.000001

var _puntos: int = 0
var _tiempo_regeneracion: float = 0.0

var puntos: int:
	get:
		return _puntos

func _init() -> void:
	_puntos = GameConfig.IMPACTOS_PARA_ABSORBER

func recibir_impacto() -> void:
	if _puntos <= 0:
		return
	_puntos -= 1
	_tiempo_regeneracion = 0.0
	puntos_cambiados.emit(_puntos)
	if _puntos == 0:
		absorbido.emit()

func avanzar_tiempo(delta: float) -> void:
	if _puntos <= 0:
		return
	if _puntos >= GameConfig.IMPACTOS_PARA_ABSORBER:
		_tiempo_regeneracion = 0.0
		return

	_tiempo_regeneracion += delta
	while (
		_puntos < GameConfig.IMPACTOS_PARA_ABSORBER
		and _tiempo_regeneracion + EPSILON >= GameConfig.TIEMPO_REGENERACION_PUNTO
	):
		_tiempo_regeneracion -= GameConfig.TIEMPO_REGENERACION_PUNTO
		_puntos += 1
		puntos_cambiados.emit(_puntos)

	if _puntos >= GameConfig.IMPACTOS_PARA_ABSORBER:
		_tiempo_regeneracion = 0.0

func esta_absorbido() -> bool:
	return _puntos <= 0

func reiniciar() -> void:
	_puntos = GameConfig.IMPACTOS_PARA_ABSORBER
	_tiempo_regeneracion = 0.0
	puntos_cambiados.emit(_puntos)
