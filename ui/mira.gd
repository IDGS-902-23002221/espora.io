extends Control

# Mira 2D de pantalla: guia el rumbo horizontal real de la espora.
const COLOR: Color = Color(0.62, 1.0, 0.82, 0.95)
const COLOR_SOMBRA: Color = Color(0.01, 0.05, 0.03, 0.85)
const LARGO: float = 7.0
const HUECO: float = 4.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(28.0, 28.0)
	size = custom_minimum_size

func _draw() -> void:
	var centro: Vector2 = size * 0.5
	# Sombra para leerse sobre cualquier fondo.
	_dibujar_cruz(centro, COLOR_SOMBRA, 3.0)
	_dibujar_cruz(centro, COLOR, 1.6)
	draw_circle(centro, 1.8, COLOR)

func _dibujar_cruz(centro: Vector2, color: Color, grosor: float) -> void:
	draw_line(centro + Vector2(-HUECO - LARGO, 0.0), centro + Vector2(-HUECO, 0.0), color, grosor, true)
	draw_line(centro + Vector2(HUECO, 0.0), centro + Vector2(HUECO + LARGO, 0.0), color, grosor, true)
	draw_line(centro + Vector2(0.0, -HUECO - LARGO), centro + Vector2(0.0, -HUECO), color, grosor, true)
	draw_line(centro + Vector2(0.0, HUECO), centro + Vector2(0.0, HUECO + LARGO), color, grosor, true)
