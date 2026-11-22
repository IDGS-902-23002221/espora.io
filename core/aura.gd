extends RefCounted

# Aura estatica barata para pickups: una esfera translucida, sin animacion.
static func crear(padre: Node3D, color: Color, radio: float, energia: float = 1.2) -> MeshInstance3D:
	var aura: MeshInstance3D = MeshInstance3D.new()
	var esfera: SphereMesh = SphereMesh.new()
	esfera.radius = radio
	esfera.height = radio * 2.0
	esfera.radial_segments = 12
	esfera.rings = 6
	aura.mesh = esfera
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(color.r, color.g, color.b, 0.16)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energia
	aura.material_override = material
	aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	padre.add_child(aura)
	return aura
