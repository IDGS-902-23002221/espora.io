extends Control

# Tres honguitos rojos para las vidas, dibujados por codigo.
const CANTIDAD: int = 3
const ANCHO: float = 40.0
const ALTO: float = 36.0
const ROJO: Color = Color(0.95, 0.20, 0.18, 1.0)
const ROJO_IMPACTO: Color = Color(1.0, 0.55, 0.20, 1.0)
const VACIO: Color = Color(0.12, 0.14, 0.13, 0.9)

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
		var color: Color = ROJO if i < _vidas else VACIO
		if i == _parpadeo:
			color = ROJO_IMPACTO
		_hongo(Vector2(i * ANCHO, 0.0), color)

func _hongo(base: Vector2, color: Color) -> void:
	# Sombrero: circulo achatado y borde inferior recto.
	var centro: Vector2 = base + Vector2(ANCHO * 0.5, 13.0)
	draw_circle(centro, 12.0, color)
	draw_rect(Rect2(base.x + 3.0, base.y + 13.0, ANCHO - 6.0, 4.0), color)
	# Tallo simple, un poco mas oscuro.
	draw_rect(Rect2(base.x + 12.0, base.y + 17.0, ANCHO - 24.0, 15.0), color.darkened(0.18))
	# Dos manchitas claras en el sombrero.
	var claro: Color = Color(1.0, 0.86, 0.78, 0.55)
	draw_circle(base + Vector2(ANCHO * 0.5 - 5.0, 8.0), 2.0, claro)
	draw_circle(base + Vector2(ANCHO * 0.5 + 4.0, 5.0), 1.6, claro)
