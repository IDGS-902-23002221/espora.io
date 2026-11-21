class_name Especies
extends RefCounted

const BiomaScript = preload("res://core/bioma.gd")

const SKIN_CLASICO: String = "clasico"
const SKIN_LUMINARIA: String = "luminaria"
const SKIN_REY: String = "rey"

const MODELO_MUSHNUB: String = "res://assets/skins/mushnub.glb"
const MODELO_LUMINARIA: String = "res://assets/skins/mushnub_evolved.glb"
const MODELO_REY: String = "res://assets/skins/mushroom_king.glb"

# Modelos CC0 de NPC por bioma (poly.pizza).
const MODELO_NPC_AMANITA: String = "res://assets/npcs/amanita.glb"
const MODELO_NPC_CUBENSIS: String = "res://assets/npcs/cubensis.glb"
const MODELO_NPC_MELENA: String = "res://assets/npcs/melena.glb"

static func modelo_para_especie(zona: int) -> String:
	match zona:
		BiomaScript.Zona.BOSQUE:
			return MODELO_NPC_AMANITA
		BiomaScript.Zona.PANTANO:
			return MODELO_NPC_CUBENSIS
		_:
			return MODELO_NPC_MELENA

static func especie_para_zona(zona: int) -> String:
	match zona:
		BiomaScript.Zona.BOSQUE:
			return "amanita"
		BiomaScript.Zona.PANTANO:
			return "cubensis"
		_:
			return "melena"

static func colores_especie(zona: int) -> Dictionary:
	match zona:
		BiomaScript.Zona.BOSQUE:
			return {
				"cuerpo": Color(0.92, 0.82, 0.62),
				"sombrero": Color(0.88, 0.12, 0.18),
			}
		BiomaScript.Zona.PANTANO:
			return {
				"cuerpo": Color(0.76, 0.66, 0.46),
				"sombrero": Color(0.52, 0.34, 0.14),
			}
		_:
			return {
				"cuerpo": Color(0.34, 0.34, 0.42),
				"sombrero": Color(0.10, 0.12, 0.22),
			}

static func colores_skin(skin: String) -> Dictionary:
	match skin:
		SKIN_LUMINARIA:
			return {
				"cuerpo": Color(0.45, 0.95, 1.0),
				"sombrero": Color(0.15, 0.75, 0.95),
				"emision": true,
				"energia": 1.2,
				"luz": Color(0.35, 0.95, 1.0),
				"luz_energia": 0.5,
			}
		SKIN_REY:
			return {
				"cuerpo": Color(0.85, 0.70, 0.40),
				"sombrero": Color(0.55, 0.25, 0.65),
				"emision": false,
				"energia": 0.0,
				"luz": Color(1.0, 0.80, 0.45),
				"luz_energia": 0.35,
			}
		_:
			return {
				"cuerpo": Color(0.78, 0.68, 0.48),
				"sombrero": Color(0.20, 0.55, 0.65),
				"emision": false,
				"energia": 0.0,
				"luz": Color(1.0, 0.85, 0.65),
				"luz_energia": 0.25,
			}

static func skins_disponibles() -> Array[String]:
	return [SKIN_CLASICO, SKIN_LUMINARIA, SKIN_REY]

static func modelo_para_skin(skin: String) -> String:
	match skin:
		SKIN_LUMINARIA:
			return MODELO_LUMINARIA
		SKIN_REY:
			return MODELO_REY
		_:
			return MODELO_MUSHNUB

static func modelo_disponible(ruta: String) -> bool:
	return ruta != "" and FileAccess.file_exists(ruta + ".import") and ResourceLoader.exists(ruta)

static func _mallas(raiz: Node3D) -> Array[MeshInstance3D]:
	var lista: Array[MeshInstance3D] = []
	var pendientes: Array[Node] = [raiz]
	while pendientes.size() > 0:
		var nodo: Node = pendientes.pop_back()
		if nodo is MeshInstance3D:
			lista.append(nodo as MeshInstance3D)
		for hijo in nodo.get_children():
			pendientes.append(hijo)
	return lista

static func _transform_relativo(raiz: Node3D, nodo: Node3D) -> Transform3D:
	var transformacion: Transform3D = nodo.transform
	var padre: Node = nodo.get_parent()
	while padre != null and padre != raiz:
		if padre is Node3D:
			transformacion = (padre as Node3D).transform * transformacion
		padre = padre.get_parent()
	return transformacion

static func normalizar_modelo(modelo: Node3D, altura_objetivo: float = 1.7) -> void:
	var mallas: Array[MeshInstance3D] = _mallas(modelo)
	if mallas.is_empty():
		return
	var caja: AABB
	var primero: bool = true
	for malla in mallas:
		var transformacion: Transform3D = _transform_relativo(modelo, malla)
		var aabb: AABB = transformacion * malla.get_aabb()
		if primero:
			caja = aabb
			primero = false
		else:
			caja = caja.merge(aabb)
	if caja.size.y <= 0.001:
		return
	var factor: float = altura_objetivo / caja.size.y
	var centro: Vector3 = caja.get_center()
	modelo.scale = Vector3.ONE * factor
	modelo.position = Vector3(-centro.x * factor, -caja.position.y * factor, -centro.z * factor)

# Tinta el modelo con los colores de la especie sin perder la textura.
static func aplicar_colores_modelo(modelo: Node3D, cuerpo: Color, sombrero: Color) -> void:
	for malla in _mallas(modelo):
		if malla.mesh == null:
			continue
		for i in malla.mesh.get_surface_count():
			var material: Material = malla.get_active_material(i)
			if material == null:
				continue
			var copia: BaseMaterial3D = material.duplicate() as BaseMaterial3D
			if copia == null:
				continue
			var nombre: String = str(copia.resource_name).to_lower()
			var color: Color = sombrero if ("light" in nombre or "cap" in nombre or "hat" in nombre) else cuerpo
			copia.albedo_color = color
			copia.emission_enabled = true
			copia.emission = sombrero
			copia.emission_energy_multiplier = 0.08
			malla.set_surface_override_material(i, copia)

static func aplicar_emision_modelo(modelo: Node3D, color: Color, energia: float) -> void:
	for malla in _mallas(modelo):
		if malla.mesh == null:
			continue
		for i in malla.mesh.get_surface_count():
			var material: Material = malla.get_active_material(i)
			if material == null:
				continue
			var copia: BaseMaterial3D = material.duplicate() as BaseMaterial3D
			if copia == null:
				continue
			if "Eye" in str(copia.resource_name):
				continue
			copia.emission_enabled = true
			copia.emission = color
			copia.emission_energy_multiplier = energia
			malla.set_surface_override_material(i, copia)

static func animacion_para_velocidad(velocidad: float) -> String:
	# Los modelos traen Walk; si no, animar_modelo cae a Idle.
	if velocidad > 0.1:
		return "Walk"
	return "Idle"

# Cambia de animacion solo cuando hace falta; el resultado se cachea en el modelo
# para no recorrer el arbol ni la lista de animaciones en cada frame.
static func animar_modelo(modelo: Node3D, velocidad: float) -> void:
	if modelo == null:
		return
	var reproductor: AnimationPlayer = _animador_cacheado(modelo)
	if reproductor == null:
		return
	var nombre: String = _animacion_cacheada(modelo, reproductor, animacion_para_velocidad(velocidad))
	if nombre == "":
		nombre = _animacion_cacheada(modelo, reproductor, "Idle")
	if nombre == "" or reproductor.current_animation == nombre:
		return
	reproductor.play(nombre)

static func reproducir_idle(modelo: Node3D) -> void:
	animar_modelo(modelo, 0.0)

static func _animador_cacheado(modelo: Node3D) -> AnimationPlayer:
	if not modelo.has_meta("animador_skin"):
		modelo.set_meta("animador_skin", _buscar_animation_player(modelo))
	return modelo.get_meta("animador_skin") as AnimationPlayer

static func _animacion_cacheada(
	modelo: Node3D, reproductor: AnimationPlayer, prefijo: String
) -> String:
	var clave: String = "anim_" + prefijo
	if not modelo.has_meta(clave):
		modelo.set_meta(clave, _buscar_animacion(reproductor, prefijo))
	return str(modelo.get_meta(clave))

static func _buscar_animation_player(raiz: Node) -> AnimationPlayer:
	var pendientes: Array[Node] = [raiz]
	while pendientes.size() > 0:
		var nodo: Node = pendientes.pop_back()
		if nodo is AnimationPlayer:
			return nodo as AnimationPlayer
		for hijo in nodo.get_children():
			pendientes.append(hijo)
	return null

static func _buscar_animacion(reproductor: AnimationPlayer, prefijo: String) -> String:
	for nombre in reproductor.get_animation_list():
		if prefijo in str(nombre):
			return str(nombre)
	return ""
