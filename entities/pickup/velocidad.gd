extends Area3D

signal recogido

const FormasScript = preload("res://core/formas.gd")

var _base_y: float = 0.0
var _tiempo: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 3
	monitorable = false
	body_entered.connect(_on_body_entered)
	_crear_colision()
	_crear_malla()
	_base_y = position.y
	_tiempo = randf() * TAU

func _process(delta: float) -> void:
	_tiempo += delta
	position.y = _base_y + sin(_tiempo * 2.0) * 0.15
	rotation.y += delta * 1.5

func _crear_colision() -> void:
	var colision: CollisionShape3D = CollisionShape3D.new()
	var forma: SphereShape3D = SphereShape3D.new()
	forma.radius = 0.8
	colision.shape = forma
	add_child(colision)

func _crear_malla() -> void:
	var raiz: Node3D = Node3D.new()
	add_child(raiz)
	# Hoja/pluma en lugar del toro violeta.
	var hoja: MeshInstance3D = MeshInstance3D.new()
	hoja.mesh = FormasScript.hoja_malla()
	hoja.material_override = _material_velocidad()
	hoja.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(hoja)
	# Estelas de viento detras de la hoja.
	for i in 3:
		var estela: MeshInstance3D = MeshInstance3D.new()
		var caja: BoxMesh = BoxMesh.new()
		caja.size = Vector3(0.05, 0.02, 0.42 + i * 0.14)
		estela.mesh = caja
		estela.material_override = _material_velocidad()
		estela.position = Vector3(0.0, 0.0, -0.30 - i * 0.12)
		estela.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		raiz.add_child(estela)

func _material_velocidad() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.4, 1.0, 0.7, 0.7)
	material.emission_enabled = true
	material.emission = Color(0.15, 0.85, 0.55)
	material.emission_energy_multiplier = 1.8
	return material

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("activar_velocidad"):
		return
	body.activar_velocidad()
	recogido.emit()
	queue_free()
