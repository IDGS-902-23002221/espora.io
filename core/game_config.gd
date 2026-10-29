class_name GameConfig
extends RefCounted

# Umbrales de tamano, empate e histeresis.
const UMBRAL_ATAQUE_ENTRADA: float = 1.10
const UMBRAL_ATAQUE_SALIDA: float = 1.05
const UMBRAL_HUIDA_ENTRADA: float = 0.90
const UMBRAL_HUIDA_SALIDA: float = 0.95
const TIEMPO_MIN_ESTADO: float = 1.0

# Tamano y crecimiento.
const TAMANIO_INICIAL: float = 1.0
const TAMANIO_MAXIMO: float = 6.0
const CRECIMIENTO_NUTRIENTE: float = 0.03
const MULT_NUTRIENTE_DORADO: float = 3.0
const FRACCION_ABSORCION: float = 0.25
const FRACCION_REAPARICION: float = 0.60
const COOLDOWN_REAPARICION_JUGADOR: float = 3.0
const COOLDOWN_REAPARICION_NPC: float = 2.0

# Velocidad.
const VELOCIDAD_BASE_JUGADOR: float = 6.0
const PENALIZACION_VELOCIDAD_POR_TAMANIO: float = 0.08
const VELOCIDAD_MINIMA_FRACCION: float = 0.60
const MULT_VELOCIDAD_ESPORA_VELOZ: float = 1.40
const DURACION_ESPORA_VELOZ: float = 4.0

# Esporas y dano.
const IMPACTOS_PARA_ABSORBER: int = 3
const VIDA_ESPORA: float = 3.5
const VELOCIDAD_ESPORA: float = 14.0
const COOLDOWN_DISPARO_JUGADOR: float = 0.6
const TIEMPO_REGENERACION_PUNTO: float = 4.0
const DURACION_ESPORA_ESCUDO: float = 5.0

# Mapa, nutrientes y topes.
const RADIO_MAPA: float = 60.0
const NUTRIENTES_ACTIVOS_MAX: int = 100
const INTERVALO_REAPARICION_NUTRIENTE: float = 0.5
const INTERVALO_NUTRIENTE_DORADO_MIN: float = 30.0
const INTERVALO_NUTRIENTE_DORADO_MAX: float = 45.0
const INTERVALO_ESPORA_ESCUDO_MIN: float = 40.0
const INTERVALO_ESPORA_ESCUDO_MAX: float = 60.0
const INTERVALO_ESPORA_VELOZ_MIN: float = 40.0
const INTERVALO_ESPORA_VELOZ_MAX: float = 60.0
const NPC_MAX_ABSOLUTO: int = 24

# Hordas: solo datos, sin logica.
# Pausa entre hordas, en segundos (valor de balance).
const PAUSA_ENTRE_HORDAS: float = 5.0
const HORDAS: Array[Dictionary] = [
	{
		"duracion": 90.0,
		"npc_por_horda": 12,
		"velocidad_npc": 5.0,
		"cooldown_disparo_npc": 1.2,
		"radio_deteccion_npc": 18.0,
		"mult_tamanio_aparicion": 1.0,
	},
	{
		"duracion": 90.0,
		"npc_por_horda": 14,
		"velocidad_npc": 5.3,
		"cooldown_disparo_npc": 1.05,
		"radio_deteccion_npc": 20.0,
		"mult_tamanio_aparicion": 1.1,
	},
	{
		"duracion": 90.0,
		"npc_por_horda": 16,
		"velocidad_npc": 5.5,
		"cooldown_disparo_npc": 0.9,
		"radio_deteccion_npc": 22.0,
		"mult_tamanio_aparicion": 1.2,
	},
	{
		"duracion": 90.0,
		"npc_por_horda": 18,
		"velocidad_npc": 5.8,
		"cooldown_disparo_npc": 0.8,
		"radio_deteccion_npc": 25.0,
		"mult_tamanio_aparicion": 1.3,
	},
	{
		"duracion": 90.0,
		"npc_por_horda": 20,
		"velocidad_npc": 6.0,
		"cooldown_disparo_npc": 0.7,
		"radio_deteccion_npc": 28.0,
		"mult_tamanio_aparicion": 1.4,
	},
]
