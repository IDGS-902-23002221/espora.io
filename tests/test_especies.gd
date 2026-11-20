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

func test_animacion_por_velocidad() -> void:
	assert_str(EspeciesScript.animacion_para_velocidad(0.0)).is_equal("Idle")
	assert_str(EspeciesScript.animacion_para_velocidad(0.1)).is_equal("Idle")
	assert_str(EspeciesScript.animacion_para_velocidad(0.11)).is_equal("Walk")
	assert_str(EspeciesScript.animacion_para_velocidad(2.0)).is_equal("Walk")
