extends Node3D

# Decoracion CC0 repartida por el mapa con MultiMesh (sin colision).
const EspeciesScript = preload("res://core/especies.gd")

const RUTAS: Array[String] = [
	"res://assets/decor/plant.glb",
	"res://assets/decor/bush.glb",
	"res://assets/decor/rocks.glb",
	"res://assets/decor/grass.glb",
	"res://assets/decor/tall_grass.glb",
	"res://assets/decor/flower.glb",
	"res://assets/decor/rocks.glb",
]
# Altura objetivo por tipo.
const ALTURAS = [1.0, 1.4, 0.7, 0.5, 0.9, 0.6, 0.22]
# Cuantas instancias de cada tipo (la ultima es piedrita chica).
const CANTIDADES = [12, 8, 12, 30, 15, 12, 20]
const RADIO_MIN: float = 6.0
const SEMILLA: int = 20261121

func _ready() -> void:
	_generar()

func _generar() -> void:
	var radio: float = GameConfig.RADIO_MAPA - 4.0
	for indice in RUTAS.size():
		var ruta: String = RUTAS[indice]
		if not EspeciesScript.modelo_disponible(ruta):
			continue
		var escena: PackedScene = load(ruta) as PackedScene
		if escena == null:
			continue
		var modelo: Node3D = escena.instantiate() as Node3D
		var mallas: Array = _mallas_relativas(modelo)
		if mallas.is_empty():
			modelo.free()
			continue
		var factor: float = _factor_altura(mallas, float(ALTURAS[indice]))
		_crear_multimallas(mallas, factor, radio, int(CANTIDADES[indice]))
		modelo.free()

func _crear_multimallas(mallas: Array, factor: float, radio: float, cantidad: int) -> void:
	var puntos: Array[Vector3] = posiciones(cantidad, SEMILLA + cantidad, radio, RADIO_MIN)
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = SEMILLA + cantidad + 1
	for malla in mallas:
		var datos: Dictionary = malla
		var mm: MultiMesh = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = datos["mesh"] as Mesh
		mm.instance_count = puntos.size()
		for i in puntos.size():
			var angulo: float = azar.randf_range(0.0, TAU)
			var escala: float = azar.randf_range(0.8, 1.35)
			var base: Transform3D = Transform3D(
				Basis(Vector3.UP, angulo).scaled(Vector3.ONE * escala),
				puntos[i]
			)
			var ajuste: Transform3D = Transform3D(
				Basis.from_scale(Vector3.ONE * factor), Vector3.ZERO
			)
			mm.set_instance_transform(i, base * ajuste * (datos["transform"] as Transform3D))
		var mmi: MultiMeshInstance3D = MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = datos["material"] as Material
		mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mmi)

# Posiciones deterministas en un anillo, sin tocar el centro de spawn.
static func posiciones(cantidad: int, semilla: int, radio: float, radio_min: float) -> Array[Vector3]:
	var lista: Array[Vector3] = []
	var azar: RandomNumberGenerator = RandomNumberGenerator.new()
	azar.seed = semilla
	var rango: float = maxf(radio - radio_min, 0.0)
	for i in cantidad:
		var angulo: float = azar.randf_range(0.0, TAU)
		var distancia: float = radio_min + sqrt(azar.randf()) * rango
		lista.append(Vector3(cos(angulo) * distancia, 0.0, sin(angulo) * distancia))
	return lista

func _mallas_relativas(raiz: Node3D) -> Array:
	var lista: Array = []
	var pendientes: Array[Node] = [raiz]
	while pendientes.size() > 0:
		var nodo: Node = pendientes.pop_back()
		if nodo is MeshInstance3D:
			var malla: MeshInstance3D = nodo as MeshInstance3D
			if malla.mesh != null:
				lista.append({
					"mesh": malla.mesh,
					"transform": _transform_relativo(raiz, malla),
					"material": malla.material_override,
				})
		for hijo in nodo.get_children():
			pendientes.append(hijo)
	return lista

func _transform_relativo(raiz: Node3D, nodo: Node3D) -> Transform3D:
	var transformacion: Transform3D = nodo.transform
	var padre: Node = nodo.get_parent()
	while padre != null and padre != raiz:
		if padre is Node3D:
			transformacion = (padre as Node3D).transform * transformacion
		padre = padre.get_parent()
	return transformacion

func _factor_altura(mallas: Array, altura_objetivo: float) -> float:
	var caja: AABB
	var primero: bool = true
	for datos in mallas:
		var transformacion: Transform3D = datos["transform"] as Transform3D
		var aabb: AABB = transformacion * (datos["mesh"] as Mesh).get_aabb()
		if primero:
			caja = aabb
			primero = false
		else:
			caja = caja.merge(aabb)
	if caja.size.y <= 0.001:
		return 1.0
	return altura_objetivo / caja.size.y
