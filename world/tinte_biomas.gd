extends Node3D

# Tintes provisionales por zona. Se generan como discos planos para no editar .tscn.
const COLOR_BOSQUE: Color = Color(0.0, 0.35, 0.32, 0.12)
const COLOR_PANTANO: Color = Color(0.22, 0.10, 0.35, 0.12)
const COLOR_CUEVA: Color = Color(0.03, 0.06, 0.16, 0.18)
const ALTURA_BASE: float = 0.02
const SEPARACION: float = 0.02
const ALTURA_DISCO: float = 0.01

func _ready() -> void:
	_crear_disco("TinteCueva", GameConfig.RADIO_MAPA, COLOR_CUEVA, ALTURA_BASE)
	_crear_disco("TintePantano", GameConfig.BIOMA_PANTANO_RADIO, COLOR_PANTANO, ALTURA_BASE + SEPARACION)
	_crear_disco("TinteBosque", GameConfig.BIOMA_BOSQUE_RADIO, COLOR_BOSQUE, ALTURA_BASE + SEPARACION * 2.0)

func _crear_disco(nombre: String, radio: float, color: Color, altura: float) -> void:
	var malla: MeshInstance3D = MeshInstance3D.new()
	malla.name = nombre
	var cilindro: CylinderMesh = CylinderMesh.new()
	cilindro.top_radius = radio
	cilindro.bottom_radius = radio
	cilindro.height = ALTURA_DISCO
	cilindro.radial_segments = 64
	malla.mesh = cilindro
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = color
	malla.material_override = material
	malla.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	malla.position = Vector3(0.0, altura, 0.0)
	add_child(malla)
