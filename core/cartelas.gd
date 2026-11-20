class_name Cartelas
extends RefCounted

# Texto exacto de HU-12 para el cierre de la apertura.
const TEXTO_APERTURA: String = "Cuando el sol se oculta, el bosque despierta. Entre las raíces, una nueva espora germina. ¿Serás tú el micelio que domine el claro antes del amanecer?"

# La apertura cuenta la historia: humanos extintos, micelio despierto y disputa por el claro.
static func apertura() -> Array:
	return [
		{
			"titulo": "PRÓLOGO",
			"subtitulo": "El mundo después de los humanos",
			"texto": "Las ciudades se apagaron. Los humanos se extinguieron. El silencio cubrió el mundo.",
			"boton": "Saltar",
		},
		{
			"titulo": "EL MICELIO DESPIERTA",
			"subtitulo": "Bajo la tierra",
			"texto": "La red de hongos se conectó. Aprendió a crecer, a esperar y a competir por la luz.",
			"boton": "Saltar",
		},
		{
			"titulo": "EL CLARO",
			"subtitulo": "Cada noche, un nuevo dueño",
			"texto": "Amanita, Cubensis y Melena se disputan el bosque. El que más absorba, domina.",
			"boton": "Saltar",
		},
		{
			"titulo": "ESPORA",
			"subtitulo": "Tú",
			"texto": TEXTO_APERTURA,
			"boton": "Saltar",
		},
	]

static func acto_i() -> Array:
	return [
		{
			"titulo": "ACTO I — GERMINACIÓN",
			"subtitulo": "La noche apenas comienza.",
			"texto": "Tu micelio es joven y el claro está lleno de rivales.",
			"boton": "Continuar",
		},
		{
			"titulo": "SOBREVIVE",
			"subtitulo": "Crece o desaparece.",
			"texto": "Comé nutrientes, esquivá a los hongos mayores y llegá al amanecer.",
			"boton": "Continuar",
		},
	]

static func acto_iv(victoria: bool) -> Array:
	if victoria:
		return [
			{
				"titulo": "ACTO IV — AMANECER",
				"subtitulo": "El sol vuelve a salir.",
				"texto": "Tu micelio resistió la noche.",
				"boton": "Continuar",
				"tinte": Color(1.0, 0.82, 0.38, 0.12),
				"particulas_color": Color(1.0, 0.85, 0.45, 0.45),
			},
			{
				"titulo": "EL CLARO ES TUYO",
				"subtitulo": "Por esta noche.",
				"texto": "Dominaste el bosque. Las otras esporas esperarán al próximo anochecer.",
				"boton": "Continuar",
				"tinte": Color(1.0, 0.90, 0.55, 0.10),
				"particulas_color": Color(1.0, 0.9, 0.55, 0.45),
			},
		]
	return [
		{
			"titulo": "ACTO IV — OSCURIDAD",
			"subtitulo": "La espora se apaga.",
			"texto": "Tu micelio se disolvió antes del amanecer.",
			"boton": "Continuar",
			"tinte": Color(0.85, 0.08, 0.10, 0.20),
			"particulas_color": Color(1.0, 0.25, 0.20, 0.45),
		},
		{
			"titulo": "EL BOSQUE SIGUE",
			"subtitulo": "Otra espora germinará.",
			"texto": "El claro espera a la próxima que se atreva a crecer.",
			"boton": "Continuar",
			"tinte": Color(0.70, 0.06, 0.08, 0.18),
			"particulas_color": Color(0.95, 0.22, 0.18, 0.42),
		},
	]
