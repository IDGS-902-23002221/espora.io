class_name Hordas
extends RefCounted

# Una horda activa -> pausa -> horda siguiente; tras la ultima, termina la partida.
enum Evento { NADA, FIN_HORDA, INICIO_HORDA, FIN_PARTIDA }

var indice: int = 0
var tiempo_restante: float = 0.0
var en_pausa: bool = false
var terminada: bool = false

func _init() -> void:
	tiempo_restante = duracion(0)

static func total() -> int:
	return GameConfig.HORDAS.size()

static func ultima() -> int:
	return total() - 1

static func es_valido(indice_horda: int) -> bool:
	return indice_horda >= 0 and indice_horda < total()

static func configuracion(indice_horda: int) -> Dictionary:
	if not es_valido(indice_horda):
		return {}
	return GameConfig.HORDAS[indice_horda]

static func duracion(indice_horda: int) -> float:
	var config: Dictionary = configuracion(indice_horda)
	if config.is_empty():
		return 0.0
	return float(config["duracion"])

# Avanza el reloj y devuelve todos los eventos cruzados, en orden.
# Con un delta grande no se pierde ninguna transicion.
func avanzar_tiempo(delta: float) -> Array:
	var eventos: Array = []
	if terminada or delta <= 0.0:
		return eventos

	var restante: float = delta
	while restante > 0.0:
		if restante < tiempo_restante:
			tiempo_restante -= restante
			break
		restante -= tiempo_restante
		tiempo_restante = 0.0
		if en_pausa:
			_iniciar_horda(indice + 1)
			eventos.append(Evento.INICIO_HORDA)
		elif indice >= ultima():
			terminada = true
			eventos.append(Evento.FIN_PARTIDA)
			break
		else:
			en_pausa = true
			tiempo_restante = GameConfig.PAUSA_ENTRE_HORDAS
			eventos.append(Evento.FIN_HORDA)
	return eventos

func reiniciar() -> void:
	indice = 0
	tiempo_restante = duracion(0)
	en_pausa = false
	terminada = false

func _iniciar_horda(nuevo_indice: int) -> void:
	indice = nuevo_indice
	en_pausa = false
	tiempo_restante = duracion(nuevo_indice)
