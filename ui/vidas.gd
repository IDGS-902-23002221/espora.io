extends Control

# Tres hojas = vida actual. Cada hoja aguanta 2 impactos.
const HOJAS: int = 3
const PUNTOS_POR_HOJA: int = 2
const PUNTOS_MAXIMOS: int = HOJAS * PUNTOS_POR_HOJA
const ANCHO: float = 40.0
const ALTO: float = 36.0
const VERDE: Color = Color(0.38, 0.92, 0.45, 1.0)
const VERDE_IMPACTO: Color = Color(1.0, 0.82, 0.30, 1.0)
const VACIO: Color = Color(0.10, 0.16, 0.11, 0.9)

var _puntos: int = PUNTOS_MAXIMOS
var _parpadeo: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(ANCHO * HOJAS, ALTO)
	size = custom_minimum_size

func mostrar(puntos: int, parpadeo: int = -1) -> void:
	var nuevos: int = clampi(puntos, 0, PUNTOS_MAXIMOS)
	if nuevos == _puntos and parpadeo == _parpadeo:
		return
	_puntos = nuevos
	_parpadeo = parpadeo
	queue_redraw()

func puntos_actuales() -> int:
	return _puntos

func _draw() -> void:
	var hoja_parpadeo: int = -1
	if _parpadeo >= 0 and _puntos > 0:
		hoja_parpadeo = clampi((_puntos - 1) / PUNTOS_POR_HOJA, 0, HOJAS - 1)
	for i in HOJAS:
		var base: Vector2 = Vector2(i * ANCHO, 0.0)
		var restantes: int = clampi(_puntos - i * PUNTOS_POR_HOJA, 0, PUNTOS_POR_HOJA)
		var color: Color = VERDE if i != hoja_parpadeo else VERDE_IMPACTO
		if restantes == PUNTOS_POR_HOJA:
			_hoja(base, color, 1.0)
		elif restantes == 1:
			# Media hoja: se borra la mitad superior.
			_hoja(base, VACIO, 1.0)
			_hoja(base, color, 0.5)
		else:
			_hoja(base, VACIO, 1.0)

func _hoja(base: Vector2, color: Color, fraccion: float = 1.0) -> void:
	var centro: Vector2 = base + Vector2(ANCHO * 0.5, ALTO * 0.5)
	var fondo: float = base.y + ALTO - 2.0
	var puntos: PackedVector2Array = PackedVector2Array()
	for i in 12:
		var t: float = TAU * float(i) / 12.0
		var local: Vector2 = Vector2(cos(t) * 9.0, sin(t) * 14.0).rotated(-0.55)
		var punto: Vector2 = centro + local
		punto.y = fondo - (fondo - punto.y) * fraccion
		puntos.append(punto)
	draw_colored_polygon(puntos, color)
	var vena_centro: Vector2 = centro
	vena_centro.y = fondo - (fondo - vena_centro.y) * fraccion
	var tallo: Color = Color(0.18, 0.42, 0.22, 0.95)
	draw_line(base + Vector2(ANCHO * 0.5, ALTO - 2.0), vena_centro, tallo, 2.2, true)
	draw_line(
		vena_centro + Vector2(-5.0, 8.0 * fraccion),
		vena_centro + Vector2(5.0, -8.0 * fraccion),
		color.darkened(0.28), 1.6, true
	)
