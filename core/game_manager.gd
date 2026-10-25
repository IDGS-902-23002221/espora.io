extends Node

enum EstadoPartida { MENU, JUGANDO, PAUSADO, TERMINADA }

var estado_partida: EstadoPartida = EstadoPartida.MENU
var puntaje: int = 0

func reiniciar() -> void:
	estado_partida = EstadoPartida.MENU
	puntaje = 0
