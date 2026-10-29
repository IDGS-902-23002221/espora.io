extends Node

enum EstadoPartida { MENU, JUGANDO, PAUSADO, TERMINADA }

var estado_partida: EstadoPartida = EstadoPartida.MENU
var puntaje: int = 0
# Estado de hordas. El avance por tiempo y el spawneo se conectan en 000.13.2.
var hordas: Hordas = Hordas.new()

var indice_horda: int:
	get:
		return hordas.indice

func configuracion_horda() -> Dictionary:
	return Hordas.configuracion(hordas.indice)

func reiniciar() -> void:
	estado_partida = EstadoPartida.MENU
	puntaje = 0
	hordas.reiniciar()
