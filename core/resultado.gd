class_name ResultadoPartida
extends RefCounted

# Textos exactos del guion para la pantalla de fin de partida.
static func textos(
	victoria: bool,
	puntos: int,
	absorbidos: int,
	tamanio_maximo: float,
	segundos: float
) -> Dictionary:
	var titulo: String
	var subtitulo: String
	if victoria:
		titulo = "¡Amanece!"
		subtitulo = "Tu micelio dominó el claro."
	else:
		titulo = "Te absorbieron"
		subtitulo = "Tu micelio se disolvió antes del amanecer."
	return {
		"titulo": titulo,
		"subtitulo": subtitulo,
		"lineas": [
			"Puntaje: %d" % puntos,
			"NPC absorbidos: %d" % absorbidos,
			"Tamaño máximo: %.1f" % tamanio_maximo,
			"Tiempo: %s" % Puntaje.formatear_tiempo(segundos),
		],
		"boton": "Jugar de nuevo",
	}
