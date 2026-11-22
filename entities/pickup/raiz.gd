extends Area3D

signal recogido

const AuraScript = preload("res://core/aura.gd")

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
	rotation.y += delta * 1.1

func _crear_colision() -> void:
	var colision: CollisionShape3D = CollisionShape3D.new()
	var forma: SphereShape3D = SphereShape3D.new()
	forma.radius = 0.9
	colision.shape = forma
	add_child(colision)

func _crear_malla() -> void:
	var raiz: Node3D = Node3D.new()
	add_child(raiz)
	var color: Color = Color(0.45, 0.95, 0.35)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, 0.85)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.6
	var toro: TorusMesh = TorusMesh.new()
	toro.inner_radius = 0.25
	toro.outer_radius = 0.48
	toro.rings = 12
	toro.ring_segments = 8
	var malla: MeshInstance3D = MeshInstance3D.new()
	malla.mesh = toro
	malla.material_override = material
	malla.rotation_degrees.x = 90.0
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(malla)
	AuraScript.crear(raiz, color, 1.0)

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("aplicar_raiz"):
		return
	body.aplicar_raiz()
	recogido.emit()
	queue_free()
