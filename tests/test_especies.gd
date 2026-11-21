extends GdUnitTestSuite

const EspeciesScript = preload("res://core/especies.gd")
const BiomaScript = preload("res://core/bioma.gd")

func test_especie_por_zona() -> void:
	assert_str(EspeciesScript.especie_para_zona(BiomaScript.Zona.BOSQUE)).is_equal("amanita")
	assert_str(EspeciesScript.especie_para_zona(BiomaScript.Zona.PANTANO)).is_equal("cubensis")
	assert_str(EspeciesScript.especie_para_zona(BiomaScript.Zona.CUEVA)).is_equal("melena")

func test_colores_por_zona_distintos() -> void:
	var bosque: Dictionary = EspeciesScript.colores_especie(BiomaScript.Zona.BOSQUE)
	var pantano: Dictionary = EspeciesScript.colores_especie(BiomaScript.Zona.PANTANO)
	var cueva: Dictionary = EspeciesScript.colores_especie(BiomaScript.Zona.CUEVA)
	assert_bool(bosque["sombrero"] != pantano["sombrero"]).is_true()
	assert_bool(pantano["sombrero"] != cueva["sombrero"]).is_true()
	assert_bool(bosque["cuerpo"] != cueva["cuerpo"]).is_true()

func test_skins_disponibles_y_colores() -> void:
	var skins: Array[String] = EspeciesScript.skins_disponibles()
	assert_int(skins.size()).is_equal(3)
	var clasico: Dictionary = EspeciesScript.colores_skin(EspeciesScript.SKIN_CLASICO)
	var luminaria: Dictionary = EspeciesScript.colores_skin(EspeciesScript.SKIN_LUMINARIA)
	var rey: Dictionary = EspeciesScript.colores_skin(EspeciesScript.SKIN_REY)
	assert_bool(clasico["emision"]).is_false()
	assert_bool(luminaria["emision"]).is_true()
	assert_bool(rey["emision"]).is_false()
	assert_bool(clasico["sombrero"] != luminaria["sombrero"]).is_true()

func test_modelos_por_skin() -> void:
	assert_str(EspeciesScript.modelo_para_skin(EspeciesScript.SKIN_CLASICO)).is_equal(EspeciesScript.MODELO_MUSHNUB)
	assert_str(EspeciesScript.modelo_para_skin(EspeciesScript.SKIN_LUMINARIA)).is_equal(EspeciesScript.MODELO_LUMINARIA)
	assert_str(EspeciesScript.modelo_para_skin(EspeciesScript.SKIN_REY)).is_equal(EspeciesScript.MODELO_REY)

func test_modelos_por_especie() -> void:
	assert_str(EspeciesScript.modelo_para_especie(BiomaScript.Zona.BOSQUE)).is_equal(EspeciesScript.MODELO_NPC_AMANITA)
	assert_str(EspeciesScript.modelo_para_especie(BiomaScript.Zona.PANTANO)).is_equal(EspeciesScript.MODELO_NPC_CUBENSIS)
	assert_str(EspeciesScript.modelo_para_especie(BiomaScript.Zona.CUEVA)).is_equal(EspeciesScript.MODELO_NPC_MELENA)

func test_modelo_npc_inexistente_no_disponible() -> void:
	assert_bool(EspeciesScript.modelo_disponible("res://assets/npcs/no_existe.glb")).is_false()

func test_colores_modelo_respetan_material() -> void:
	var raiz: Node3D = Node3D.new()
	var malla: MeshInstance3D = MeshInstance3D.new()
	malla.mesh = BoxMesh.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	malla.material_override = material
	raiz.add_child(malla)
	EspeciesScript.aplicar_colores_modelo(raiz, Color(0.1, 0.2, 0.3), Color(0.4, 0.5, 0.6))
	var resultado: StandardMaterial3D = malla.get_surface_override_material(0) as StandardMaterial3D
	assert_object(resultado).is_not_null()
	assert_bool(resultado.albedo_color.is_equal_approx(Color(0.1, 0.2, 0.3))).is_true()
	raiz.free()

func test_animacion_por_velocidad() -> void:
	assert_str(EspeciesScript.animacion_para_velocidad(0.0)).is_equal("Idle")
	assert_str(EspeciesScript.animacion_para_velocidad(0.1)).is_equal("Idle")
	assert_str(EspeciesScript.animacion_para_velocidad(0.11)).is_equal("Walk")
	assert_str(EspeciesScript.animacion_para_velocidad(2.0)).is_equal("Walk")
