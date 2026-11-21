extends Control

# Adorno de bosque dibujado por codigo: esporas, raices y hongos.
# No usa texturas ni .tscn; se estira al tamano de la pantalla.

const ESPORAS: int = 30
const COLOR_RAMA: Color = Color(0.22, 0.55, 0.32, 0.20)
const COLOR_HOJA: Color = Color(0.20, 0.48, 0.28, 0.16)
const COLOR_HONGO: Color = Color(0.55, 0.82, 0.58, 0.22)
const COLOR_TALLO: Color = Color(0.40, 0.62, 0.44, 0.18)

var _puntos: Array[Vector3] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preparar_puntos()
	resized.connect(queue_redraw)

func _preparar_puntos() -> void:
	# Semilla fija: el adorno no cambia entre menus.
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = 20261121
	for i in ESPORAS:
		_puntos.append(Vector3(azar.randf(), azar.randf(), azar.randf_range(1.0, 3.0)))

func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	_dibujar_esporas()
	_dibujar_raices(Vector2(0.0, size.y), 1.0)
	_dibujar_raices(Vector2(size.x, size.y), -1.0)
	_dibujar_hojas(Vector2(0.0, 0.0), 1.0)
	_dibujar_hojas(Vector2(size.x, 0.0), -1.0)
	_dibujar_hongo(Vector2(46.0, size.y - 12.0), 1.0)
	_dibujar_hongo(Vector2(size.x - 46.0, size.y - 12.0), 1.0)

func _dibujar_esporas() -> void:
	for p in _puntos:
		var centro: Vector2 = Vector2(p.x * size.x, p.y * size.y)
		# Halo tenue + nucleo brillante.
		draw_circle(centro, p.z * 2.6, Color(0.45, 1.0, 0.70, 0.035))
		draw_circle(centro, p.z * 0.7, Color(0.65, 1.0, 0.80, 0.16))

func _dibujar_raices(esquina: Vector2, dir: float) -> void:
	for i in 3:
		var alto: float = 42.0 + i * 26.0
		var ancho: float = 70.0 + i * 34.0
		var puntos: PackedVector2Array = PackedVector2Array([
			esquina,
			esquina + Vector2(dir * ancho * 0.35, -alto * 0.45),
			esquina + Vector2(dir * ancho * 0.60, -alto * 0.35),
			esquina + Vector2(dir * ancho, -alto),
		])
		draw_polyline(puntos, COLOR_RAMA, 3.0, true)
		# Ramita secundaria.
		var medio: Vector2 = puntos[1]
		draw_line(medio, medio + Vector2(dir * 24.0, -18.0), COLOR_RAMA, 2.0, true)

func _dibujar_hojas(esquina: Vector2, dir: float) -> void:
	for i in 3:
		var centro: Vector2 = esquina + Vector2(dir * (28.0 + i * 34.0), 34.0 + i * 22.0)
		_hoja(centro, dir * (0.5 + i * 0.35), 18.0, 7.0)
		_hoja(centro + Vector2(dir * 14.0, 14.0), dir * (-0.2 + i * 0.3), 13.0, 5.0)

func _hoja(centro: Vector2, angulo: float, largo: float, ancho: float) -> void:
	var puntos: PackedVector2Array = PackedVector2Array()
	for i in 12:
		var t: float = TAU * float(i) / 12.0
		# Forma de hoja: elipse inclinada con punta.
		var local: Vector2 = Vector2(cos(t) * largo, sin(t) * ancho)
		puntos.append(centro + local.rotated(angulo))
	draw_colored_polygon(puntos, COLOR_HOJA)

func _dibujar_hongo(base: Vector2, escala: float) -> void:
	# Tallo y sombrero de hongo en la esquina inferior.
	draw_line(base, base + Vector2(0.0, -20.0 * escala), COLOR_TALLO, 4.0 * escala, true)
	draw_arc(
		base + Vector2(0.0, -20.0 * escala),
		16.0 * escala, PI, TAU, 18, COLOR_HONGO, 6.0 * escala, true
	)
