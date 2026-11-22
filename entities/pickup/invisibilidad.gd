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
	rotation.y += delta * 0.9

func _crear_colision() -> void:
	var colision: CollisionShape3D = CollisionShape3D.new()
	var forma: SphereShape3D = SphereShape3D.new()
	forma.radius = 0.9
	colision.shape = forma
	add_child(colision)

func _crear_malla() -> void:
	var raiz: Node3D = Node3D.new()
	add_child(raiz)
	var color: Color = Color(0.55, 0.75, 1.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, 0.45)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.5
	var esfera: SphereMesh = SphereMesh.new()
	esfera.radius = 0.42
	esfera.height = 0.84
	esfera.radial_segments = 12
	esfera.rings = 6
	var malla: MeshInstance3D = MeshInstance3D.new()
	malla.mesh = esfera
	malla.material_override = material
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	raiz.add_child(malla)
	AuraScript.crear(raiz, color, 1.0, 1.0)

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("activar_invisibilidad"):
		return
	body.activar_invisibilidad()
	recogido.emit()
	queue_free()
