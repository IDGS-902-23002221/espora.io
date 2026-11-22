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
	# Aura estatica: solo gira, no sube y baja.
	_tiempo += delta
	rotation.y += delta * 1.2

func _crear_colision() -> void:
	var colision: CollisionShape3D = CollisionShape3D.new()
	var forma: SphereShape3D = SphereShape3D.new()
	forma.radius = 0.9
	colision.shape = forma
	add_child(colision)

func _crear_malla() -> void:
	var raiz: Node3D = Node3D.new()
	add_child(raiz)
	var color: Color = Color(0.55, 1.0, 0.55)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.0
	for horizontal in [true, false]:
		var barra: MeshInstance3D = MeshInstance3D.new()
		var caja: BoxMesh = BoxMesh.new()
		caja.size = Vector3(0.62, 0.16, 0.16) if horizontal else Vector3(0.16, 0.62, 0.16)
		barra.mesh = caja
		barra.material_override = material
		barra.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		raiz.add_child(barra)
	AuraScript.crear(raiz, color, 0.95)

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("recuperar_vida"):
		return
	body.recuperar_vida()
	recogido.emit()
	queue_free()
