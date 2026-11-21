extends RefCounted

# Cache de fuentes y texturas: los menus se crean varias veces y no hace falta
# reinstanciar SystemFont/GradientTexture2D en cada uno.
static var _fuentes: Dictionary = {}
static var _tex_fondo: GradientTexture2D
static var _tex_glow: GradientTexture2D

static func fuente(peso: int = 400) -> SystemFont:
	if _fuentes.has(peso):
		return _fuentes[peso] as SystemFont
	var f: SystemFont = SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Arial", "sans-serif"])
	f.font_weight = peso
	_fuentes[peso] = f
	return f

static func aplicar_titulo(etiqueta: Label, tamano: int) -> void:
	etiqueta.add_theme_font_override("font", fuente(700))
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", Color(0.45, 1.0, 1.0))
	etiqueta.add_theme_color_override("font_outline_color", Color(0.0, 0.07, 0.10, 1.0))
	etiqueta.add_theme_constant_override("outline_size", 10)
	etiqueta.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	etiqueta.add_theme_constant_override("shadow_offset_x", 4)
	etiqueta.add_theme_constant_override("shadow_offset_y", 4)

static func panel() -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = Color(0.02, 0.04, 0.08, 0.92)
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.border_color = Color(0.2, 0.8, 0.9, 0.45)
	s.corner_radius_top_left = 20
	s.corner_radius_top_right = 20
	s.corner_radius_bottom_left = 20
	s.corner_radius_bottom_right = 20
	s.content_margin_left = 48.0
	s.content_margin_right = 48.0
	s.content_margin_top = 40.0
	s.content_margin_bottom = 40.0
	s.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
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
	var borde: Color = Color(0.9, 0.3, 0.38) if peligro else Color(0.2, 0.8, 0.9)
	boton.add_theme_font_override("font", fuente(600))
	boton.add_theme_font_size_override("font_size", 22)
	boton.add_theme_color_override("font_color", Color(0.85, 0.96, 1.0))
	boton.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	boton.add_theme_color_override("font_pressed_color", Color(0.7, 0.9, 1.0))
	boton.add_theme_color_override("font_disabled_color", Color(0.45, 0.45, 0.5))
	boton.add_theme_stylebox_override("normal", _boton_base(borde, Color(0.03, 0.08, 0.12, 0.95)))
	boton.add_theme_stylebox_override("hover", _boton_base(borde.lightened(0.2), Color(0.05, 0.14, 0.20, 0.98)))
	boton.add_theme_stylebox_override("pressed", _boton_base(borde.darkened(0.2), Color(0.02, 0.05, 0.08, 1.0)))
	boton.add_theme_stylebox_override("focus", _boton_base(borde.lightened(0.35), Color(0.0, 0.0, 0.0, 0.0)))
	boton.add_theme_stylebox_override("disabled", _boton_base(Color(0.3, 0.3, 0.35, 0.6), Color(0.05, 0.05, 0.07, 0.8)))

static func fondo_gradiente() -> TextureRect:
	if _tex_fondo == null:
		var gradiente: Gradient = Gradient.new()
		gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		gradiente.colors = PackedColorArray([
			Color(0.01, 0.02, 0.06, 1.0),
			Color(0.02, 0.06, 0.13, 1.0),
			Color(0.08, 0.02, 0.14, 1.0),
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
			Color(0.2, 0.85, 0.95, 0.18),
			Color(0.1, 0.4, 0.5, 0.05),
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
