extends RefCounted

# Paleta de bosque: verdes profundos, musgo y acentos bioluminiscentes.
const FONDO_BOSQUE: Color = Color(0.008, 0.03, 0.02, 1.0)
const FONDO_MUSGO: Color = Color(0.02, 0.08, 0.055, 1.0)
const FONDO_NIEBLA: Color = Color(0.035, 0.11, 0.10, 1.0)
const PANEL_FONDO: Color = Color(0.016, 0.05, 0.038, 0.94)
const BORDE: Color = Color(0.32, 0.68, 0.44, 0.55)
const ACENTO: Color = Color(0.52, 1.0, 0.78, 1.0)
const ACENTO_TENUE: Color = Color(0.62, 0.88, 0.72, 1.0)
const TEXTO: Color = Color(0.86, 0.96, 0.88, 1.0)
const TEXTO_TENUE: Color = Color(0.62, 0.80, 0.69, 1.0)
const DORADO: Color = Color(0.95, 0.82, 0.38, 1.0)
const PELIGRO: Color = Color(0.92, 0.45, 0.36, 1.0)
const MUSGO: Color = Color(0.10, 0.22, 0.14, 1.0)

# Cache de fuentes y texturas: los menus se crean varias veces y no hace falta
# reinstanciar SystemFont/GradientTexture2D en cada uno.
static var _fuentes: Dictionary = {}
static var _tex_fondo: GradientTexture2D
static var _tex_glow: GradientTexture2D

# Tipografia natural: serif del sistema, con alternativas conocidas.
static func fuente(peso: int = 400) -> SystemFont:
	if _fuentes.has(peso):
		return _fuentes[peso] as SystemFont
	var f: SystemFont = SystemFont.new()
	f.font_names = PackedStringArray([
		"Georgia", "Cambria", "Palatino Linotype", "Book Antiqua",
		"Times New Roman", "serif",
	])
	f.font_weight = peso
	_fuentes[peso] = f
	return f

static func aplicar_titulo(etiqueta: Label, tamano: int) -> void:
	etiqueta.add_theme_font_override("font", fuente(700))
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", ACENTO)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.005, 0.04, 0.025, 1.0))
	etiqueta.add_theme_constant_override("outline_size", 8)
	etiqueta.add_theme_color_override("font_shadow_color", Color(0.0, 0.02, 0.01, 0.6))
	etiqueta.add_theme_constant_override("shadow_offset_x", 3)
	etiqueta.add_theme_constant_override("shadow_offset_y", 4)

# Texto comun con contorno suave para leerse sobre el bosque.
static func aplicar_texto(etiqueta: Label, tamano: int, color: Color = Color(0.86, 0.96, 0.88), peso: int = 400) -> void:
	etiqueta.add_theme_font_override("font", fuente(peso))
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.005, 0.04, 0.025, 0.9))
	etiqueta.add_theme_constant_override("outline_size", 4)

static func panel() -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = PANEL_FONDO
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.border_color = BORDE
	s.corner_radius_top_left = 18
	s.corner_radius_top_right = 18
	s.corner_radius_bottom_left = 18
	s.corner_radius_bottom_right = 18
	s.content_margin_left = 48.0
	s.content_margin_right = 48.0
	s.content_margin_top = 40.0
	s.content_margin_bottom = 40.0
	s.shadow_color = Color(0.0, 0.02, 0.01, 0.55)
	s.shadow_size = 24
	return s

static func _boton_base(color_borde: Color, color_fondo: Color) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = color_fondo
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.border_color = color_borde
	s.corner_radius_top_left = 10
	s.corner_radius_top_right = 10
	s.corner_radius_bottom_left = 10
	s.corner_radius_bottom_right = 10
	s.content_margin_left = 24.0
	s.content_margin_right = 24.0
	s.content_margin_top = 12.0
	s.content_margin_bottom = 12.0
	return s

static func aplicar_boton(boton: Button, peligro: bool = false) -> void:
	var borde: Color = PELIGRO if peligro else BORDE.lightened(0.12)
	boton.add_theme_font_override("font", fuente(600))
	boton.add_theme_font_size_override("font_size", 22)
	boton.add_theme_color_override("font_color", TEXTO)
	boton.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	boton.add_theme_color_override("font_pressed_color", ACENTO_TENUE)
	boton.add_theme_color_override("font_disabled_color", Color(0.40, 0.48, 0.42))
	boton.add_theme_stylebox_override("normal", _boton_base(borde, Color(0.025, 0.085, 0.06, 0.95)))
	boton.add_theme_stylebox_override("hover", _boton_base(borde.lightened(0.2), Color(0.045, 0.15, 0.10, 0.98)))
	boton.add_theme_stylebox_override("pressed", _boton_base(borde.darkened(0.2), Color(0.012, 0.05, 0.035, 1.0)))
	boton.add_theme_stylebox_override("focus", _boton_base(borde.lightened(0.35), Color(0.0, 0.0, 0.0, 0.0)))
	boton.add_theme_stylebox_override("disabled", _boton_base(Color(0.22, 0.30, 0.24, 0.6), Color(0.03, 0.06, 0.05, 0.8)))

static func fondo_gradiente() -> TextureRect:
	if _tex_fondo == null:
		var gradiente: Gradient = Gradient.new()
		gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		gradiente.colors = PackedColorArray([
			FONDO_BOSQUE,
			FONDO_MUSGO,
			FONDO_NIEBLA,
		])
		_tex_fondo = GradientTexture2D.new()
		_tex_fondo.gradient = gradiente
		_tex_fondo.width = 64
		_tex_fondo.height = 256
		_tex_fondo.fill_from = Vector2(0.0, 0.0)
		_tex_fondo.fill_to = Vector2(0.0, 1.0)
	var rect: TextureRect = TextureRect.new()
	rect.texture = _tex_fondo
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

static func glow_radial() -> TextureRect:
	if _tex_glow == null:
		var gradiente: Gradient = Gradient.new()
		gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		gradiente.colors = PackedColorArray([
			Color(0.35, 0.95, 0.70, 0.16),
			Color(0.12, 0.45, 0.30, 0.05),
			Color(0.0, 0.0, 0.0, 0.0),
		])
		_tex_glow = GradientTexture2D.new()
		_tex_glow.gradient = gradiente
		_tex_glow.width = 256
		_tex_glow.height = 256
		_tex_glow.fill = GradientTexture2D.FILL_RADIAL
		_tex_glow.fill_from = Vector2(0.5, 0.5)
		_tex_glow.fill_to = Vector2(1.0, 0.5)
	var rect: TextureRect = TextureRect.new()
	rect.texture = _tex_glow
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

static func barra(color: Color) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	return s

# Adorno dibujado por codigo: esporas, micelio, hojas y sombreros.
static func adorno_bosque() -> Control:
	var AdornoScript = preload("res://ui/adorno_bosque.gd")
	return AdornoScript.new() as Control
