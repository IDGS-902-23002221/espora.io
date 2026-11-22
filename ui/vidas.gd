extends Control

# Tres hojas verdes para las vidas, dibujadas por codigo.
const CANTIDAD: int = 3
const ANCHO: float = 40.0
const ALTO: float = 36.0
const VERDE: Color = Color(0.38, 0.92, 0.45, 1.0)
const VERDE_IMPACTO: Color = Color(1.0, 0.82, 0.30, 1.0)
const VACIO: Color = Color(0.10, 0.16, 0.11, 0.9)

var _vidas: int = CANTIDAD
var _parpadeo: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(ANCHO * CANTIDAD, ALTO)
	size = custom_minimum_size

func mostrar(vidas: int, parpadeo: int = -1) -> void:
	var nuevo: int = clampi(vidas, 0, CANTIDAD)
	if nuevo == _vidas and parpadeo == _parpadeo:
		return
	_vidas = nuevo
	_parpadeo = parpadeo
	queue_redraw()

func vidas_actuales() -> int:
	return _vidas

func _draw() -> void:
	for i in CANTIDAD:
		var color: Color = VERDE if i < _vidas else VACIO
		if i == _parpadeo:
			color = VERDE_IMPACTO
		_hoja(Vector2(i * ANCHO, 0.0), color)

func _hoja(base: Vector2, color: Color) -> void:
	var centro: Vector2 = base + Vector2(ANCHO * 0.5, ALTO * 0.5)
	var puntos: PackedVector2Array = PackedVector2Array()
	# Hoja inclinada: dos triangulos suaves alrededor del centro.
	for i in 12:
		var t: float = TAU * float(i) / 12.0
		var local: Vector2 = Vector2(cos(t) * 9.0, sin(t) * 14.0).rotated(-0.55)
		puntos.append(centro + local)
	draw_colored_polygon(puntos, color)
	# Tallo y vena central.
	var tallo: Color = Color(0.18, 0.42, 0.22, 0.95)
	draw_line(base + Vector2(ANCHO * 0.5, ALTO - 2.0), centro, tallo, 2.2, true)
	draw_line(centro + Vector2(-5.0, 8.0), centro + Vector2(5.0, -8.0), color.darkened(0.28), 1.6, true)
