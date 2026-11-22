extends RefCounted

const MAXIMO: int = 16
const MINIMO: int = 2
const DEFECTO: String = "Jugador"

static func normalizar(texto: String) -> String:
	var limpio: String = texto.strip_edges()
	if limpio.length() < MINIMO:
		return DEFECTO
	return limpio.left(MAXIMO)
