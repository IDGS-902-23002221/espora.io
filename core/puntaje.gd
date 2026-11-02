class_name Puntaje
extends RefCounted

signal puntaje_cambiado(total: int)
signal intentos_cambiados(restantes: int)
signal derrota

var puntos: int = 0
var intentos: int = GameConfig.INTENTOS_INICIALES
var absorbidos: int = 0
var tamanio_maximo: float = GameConfig.TAMANIO_INICIAL
var tiempo: float = 0.0

func sumar_nutriente() -> void:
	puntos += GameConfig.PUNTOS_POR_NUTRIENTE
	puntaje_cambiado.emit(puntos)

func registrar_absorcion() -> void:
	puntos += GameConfig.PUNTOS_POR_ABSORCION
	absorbidos += 1
	puntaje_cambiado.emit(puntos)

func sumar_horda() -> void:
	puntos += GameConfig.PUNTOS_POR_HORDA_SUPERADA
	puntaje_cambiado.emit(puntos)

func perder_intento() -> void:
	if intentos <= 0:
		return
	intentos -= 1
	intentos_cambiados.emit(intentos)
	if intentos == 0:
		derrota.emit()

func registrar_tamanio(tamanio: float) -> void:
	tamanio_maximo = maxf(tamanio_maximo, tamanio)

func avanzar_tiempo(delta: float) -> void:
	tiempo += delta

func reiniciar() -> void:
	puntos = 0
	intentos = GameConfig.INTENTOS_INICIALES
	absorbidos = 0
	tamanio_maximo = GameConfig.TAMANIO_INICIAL
	tiempo = 0.0
	puntaje_cambiado.emit(puntos)
	intentos_cambiados.emit(intentos)

# MM:SS con dos digitos en cada parte (maximo de una partida: 07:50).
static func formatear_tiempo(segundos: float) -> String:
	var total: int = maxi(int(segundos), 0)
	var minutos: int = int(total / 60.0)
	return "%02d:%02d" % [minutos, total % 60]
