extends RefCounted

# Formas simples compartidas por pickups y efectos (sin assets extra).
static func hoja_malla() -> ArrayMesh:
	var superficie: SurfaceTool = SurfaceTool.new()
	superficie.begin(Mesh.PRIMITIVE_TRIANGLES)
	var puntos: Array[Vector3] = [
		Vector3(0.0, 0.55, 0.02),
		Vector3(-0.24, 0.10, 0.0),
		Vector3(0.24, 0.10, 0.0),
		Vector3(0.0, -0.38, 0.02),
	]
	# Dos triangulos: punta y base.
	for indice in [0, 1, 2, 1, 3, 2]:
		superficie.set_normal(Vector3(0.0, 0.0, 1.0))
		superficie.add_vertex(puntos[indice])
	superficie.generate_normals()
	return superficie.commit() as ArrayMesh
