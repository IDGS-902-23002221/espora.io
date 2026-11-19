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
	var toro: TorusMesh = TorusMesh.new()
	toro.inner_radius = 0.3
	toro.outer_radius = 0.55
	toro.rings = 12
	toro.ring_segments = 8
	malla.mesh = toro
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.55, 0.35, 1.0, 0.7)
	material.emission_enabled = true
	material.emission = Color(0.45, 0.2, 1.0)
	material.emission_energy_multiplier = 2.0
	malla.material_override = material
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(malla)

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("activar_velocidad"):
		return
	body.activar_velocidad()
	recogido.emit()
	queue_free()
