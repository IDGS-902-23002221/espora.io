extends Node

enum EstadoPartida { MENU, JUGANDO, PAUSADO, TERMINADA }

var estado_partida: EstadoPartida = EstadoPartida.MENU
# Estado de hordas. El avance por tiempo y el spawneo se conectan en 000.13.2.
var hordas: Hordas = Hordas.new()
# Puntaje, intentos y estadisticas de la partida actual.
var progreso: Puntaje = Puntaje.new()
var victoria: bool = false

var indice_horda: int:
	get:
		return hordas.indice

func configuracion_horda() -> Dictionary:
	return Hordas.configuracion(hordas.indice)

func iniciar_partida() -> void:
	estado_partida = EstadoPartida.JUGANDO
	victoria = false
	hordas.reiniciar()
	progreso.reiniciar()

func esta_jugando() -> bool:
	return estado_partida == EstadoPartida.JUGANDO

func terminar_partida(es_victoria: bool = false) -> void:
	victoria = es_victoria
	estado_partida = EstadoPartida.TERMINADA

func reiniciar() -> void:
	estado_partida = EstadoPartida.MENU
	victoria = false
	hordas.reiniciar()
	progreso.reiniciar()
