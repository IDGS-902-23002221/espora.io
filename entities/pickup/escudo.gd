extends Area3D

signal recogido

var _base_y: float = 0.0
var _tiempo: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
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
	var malla: MeshInstance3D = MeshInstance3D.new()
	var esfera: SphereMesh = SphereMesh.new()
	esfera.radius = 0.45
	esfera.height = 0.9
	esfera.radial_segments = 12
	esfera.rings = 6
	malla.mesh = esfera
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.3, 1.0, 0.55, 0.65)
	material.emission_enabled = true
	material.emission = Color(0.1, 0.9, 0.35)
	material.emission_energy_multiplier = 2.0
	malla.material_override = material
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(malla)

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("activar_escudo"):
		return
	body.activar_escudo()
	recogido.emit()
	queue_free()
