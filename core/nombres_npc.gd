class_name NombresNpc
extends RefCounted

# Nombres genericos de hongos para los NPC.
const NOMBRES: Array[String] = [
	"Esporina", "Micelio", "Seta", "Honguito", "Capuchón", "Rizomorfo",
	"Glóbulo", "Boleto", "Trufa", "Píleo", "Estípite", "Liquen",
	"Saprófito", "Micorriza", "Mohito", "Amanita", "Cubensis", "Melena",
]

static func nombre_aleatorio() -> String:
	return NOMBRES[randi() % NOMBRES.size()]

# Tier visual segun el tamano actual del NPC.
static func tier_para_tamanio(tamanio: float) -> String:
	if tamanio < 1.0:
		return "Enano"
	if tamanio < 2.0:
		return "Joven"
	if tamanio < 4.0:
		return "Adulto"
	return "Coloso"
