class_name Bioma
extends RefCounted

enum Zona { BOSQUE, PANTANO, CUEVA }

# Zona segun la distancia al centro de la arena.
static func zona_para_radio(radio: float) -> Zona:
	if radio < GameConfig.BIOMA_BOSQUE_RADIO:
		return Zona.BOSQUE
	if radio < GameConfig.BIOMA_PANTANO_RADIO:
		return Zona.PANTANO
	return Zona.CUEVA

static func densidad(zona: Zona) -> float:
	match zona:
		Zona.BOSQUE:
			return GameConfig.BIOMA_BOSQUE_DENSIDAD
		Zona.PANTANO:
			return GameConfig.BIOMA_PANTANO_DENSIDAD
		_:
			return GameConfig.BIOMA_CUEVA_DENSIDAD

static func tamanio_min(zona: Zona) -> float:
	match zona:
		Zona.BOSQUE:
			return GameConfig.BIOMA_BOSQUE_NPC_MIN
		Zona.PANTANO:
			return GameConfig.BIOMA_PANTANO_NPC_MIN
		_:
			return GameConfig.BIOMA_CUEVA_NPC_MIN

static func tamanio_max(zona: Zona) -> float:
	match zona:
		Zona.BOSQUE:
			return GameConfig.BIOMA_BOSQUE_NPC_MAX
		Zona.PANTANO:
			return GameConfig.BIOMA_PANTANO_NPC_MAX
		_:
			return GameConfig.BIOMA_CUEVA_NPC_MAX

static func _radios(zona: Zona) -> Vector2:
	match zona:
		Zona.BOSQUE:
			return Vector2(0.0, GameConfig.BIOMA_BOSQUE_RADIO)
		Zona.PANTANO:
			return Vector2(GameConfig.BIOMA_BOSQUE_RADIO, GameConfig.BIOMA_PANTANO_RADIO)
		_:
			return Vector2(GameConfig.BIOMA_PANTANO_RADIO, GameConfig.RADIO_MAPA)

# Area del anillo; se usa con la densidad para ponderar el muestreo.
static func area(zona: Zona) -> float:
	var radios: Vector2 = _radios(zona)
	return PI * (radios.y * radios.y - radios.x * radios.x)

static func peso(zona: Zona) -> float:
	return area(zona) * densidad(zona)

static func peso_total() -> float:
	return peso(Zona.BOSQUE) + peso(Zona.PANTANO) + peso(Zona.CUEVA)

static func probabilidad_zona(zona: Zona) -> float:
	return peso(zona) / peso_total()

# Muestreo radial ponderado: primero elige zona por area x densidad y luego
# un radio uniforme dentro del anillo de esa zona.
static func radio_ponderado(azar_zona: float, azar_radio: float) -> float:
	var p_bosque: float = probabilidad_zona(Zona.BOSQUE)
	var p_pantano: float = probabilidad_zona(Zona.PANTANO)
	var zona: Zona = Zona.CUEVA
	if azar_zona < p_bosque:
		zona = Zona.BOSQUE
	elif azar_zona < p_bosque + p_pantano:
		zona = Zona.PANTANO
	return radio_en_zona(zona, azar_radio)

# Radio uniforme por area dentro del anillo de la zona.
static func radio_en_zona(zona: Zona, azar: float) -> float:
	var radios: Vector2 = _radios(zona)
	var r0: float = radios.x
	var r1: float = radios.y
	return sqrt(r0 * r0 + clampf(azar, 0.0, 1.0) * (r1 * r1 - r0 * r0))

# Tamano de aparicion del NPC: rango de su zona x multiplicador de horda.
static func tamanio_npc(zona: Zona, multiplicador: float, azar: float) -> float:
	var base: float = lerpf(tamanio_min(zona), tamanio_max(zona), clampf(azar, 0.0, 1.0))
	return minf(base * multiplicador, GameConfig.TAMANIO_MAXIMO)

static func es_roamer(zona: Zona, azar: float) -> bool:
	return zona == Zona.CUEVA and azar < GameConfig.ROAMER_CUEVA_PROBABILIDAD

static func tamanio_roamer(multiplicador: float) -> float:
	return minf(GameConfig.ROAMER_CUEVA_TAMANIO * multiplicador, GameConfig.TAMANIO_MAXIMO)
