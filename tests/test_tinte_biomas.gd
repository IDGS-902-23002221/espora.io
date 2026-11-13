extends GdUnitTestSuite

const TinteBiomasScript = preload("res://world/tinte_biomas.gd")

func _crear_tinte() -> Node3D:
	var tinte: Node3D = TinteBiomasScript.new() as Node3D
	add_child(tinte)
	return tinte

func test_crea_tres_discos_con_sus_radios() -> void:
	var tinte: Node3D = _crear_tinte()
	assert_int(tinte.get_child_count()).is_equal(3)
	var cueva: CylinderMesh = (tinte.get_node("TinteCueva") as MeshInstance3D).mesh as CylinderMesh
	var pantano: CylinderMesh = (tinte.get_node("TintePantano") as MeshInstance3D).mesh as CylinderMesh
	var bosque: CylinderMesh = (tinte.get_node("TinteBosque") as MeshInstance3D).mesh as CylinderMesh
	assert_float(cueva.top_radius).is_equal_approx(GameConfig.RADIO_MAPA, 0.0001)
	assert_float(pantano.top_radius).is_equal_approx(GameConfig.BIOMA_PANTANO_RADIO, 0.0001)
	assert_float(bosque.top_radius).is_equal_approx(GameConfig.BIOMA_BOSQUE_RADIO, 0.0001)
	tinte.free()

func test_materiales_unshaded_y_transparentes() -> void:
	var tinte: Node3D = _crear_tinte()
	var bosque: MeshInstance3D = tinte.get_node("TinteBosque") as MeshInstance3D
	var material: StandardMaterial3D = bosque.material_override as StandardMaterial3D
	assert_int(material.shading_mode).is_equal(BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_int(material.transparency).is_equal(BaseMaterial3D.TRANSPARENCY_ALPHA)
	assert_bool(material.albedo_color == TinteBiomasScript.COLOR_BOSQUE).is_true()
	tinte.free()

func test_discos_en_alturas_distintas_sin_sombras() -> void:
	var tinte: Node3D = _crear_tinte()
	var alturas: Array[float] = []
	for hijo in tinte.get_children():
		var malla: MeshInstance3D = hijo as MeshInstance3D
		alturas.append(malla.position.y)
		assert_int(malla.cast_shadow).is_equal(GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_int(alturas.size()).is_equal(3)
	assert_float(alturas[0]).is_not_equal(alturas[1])
	assert_float(alturas[1]).is_not_equal(alturas[2])
	tinte.free()
