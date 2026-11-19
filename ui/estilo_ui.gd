extends RefCounted

static func fuente(peso: int = 400) -> SystemFont:
	var f: SystemFont = SystemFont.new()
	f.font_names = PackedStringArray(["Segoe UI", "Arial", "sans-serif"])
	f.font_weight = peso
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
	var gradiente: Gradient = Gradient.new()
	gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradiente.colors = PackedColorArray([
		Color(0.01, 0.02, 0.06, 1.0),
		Color(0.02, 0.06, 0.13, 1.0),
		Color(0.08, 0.02, 0.14, 1.0),
	])
	var textura: GradientTexture2D = GradientTexture2D.new()
	textura.gradient = gradiente
	textura.width = 64
	textura.height = 256
	textura.fill_from = Vector2(0.0, 0.0)
	textura.fill_to = Vector2(0.0, 1.0)
	var rect: TextureRect = TextureRect.new()
	rect.texture = textura
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

static func glow_radial() -> TextureRect:
	var gradiente: Gradient = Gradient.new()
	gradiente.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradiente.colors = PackedColorArray([
		Color(0.2, 0.85, 0.95, 0.18),
		Color(0.1, 0.4, 0.5, 0.05),
		Color(0.0, 0.0, 0.0, 0.0),
	])
	var textura: GradientTexture2D = GradientTexture2D.new()
	textura.gradient = gradiente
	textura.width = 256
	textura.height = 256
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)
	var rect: TextureRect = TextureRect.new()
	rect.texture = textura
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
