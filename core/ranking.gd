class_name Ranking
extends RefCounted

# Ranking en vivo: solo ordena y calcula puntos; la UI lo dibuja.
const MAXIMO: int = 5
# Puntos cosmeticos derivados del tamanio (no toca gameplay).
const ESCALA_PUNTOS: float = 100.0

static func puntos_para(tamanio: float) -> int:
	return maxi(0, int(floor(maxf(tamanio, 0.0) * ESCALA_PUNTOS)))

static func entrada(nombre: String, tamanio: float, es_jugador: bool = false) -> Dictionary:
	var t: float = maxf(tamanio, 0.0)
	return {
		"nombre": nombre.strip_edges(),
		"tamanio": t,
		"puntos": puntos_para(t),
		"es_jugador": es_jugador,
	}

# Ordena por tamanio y luego puntos; corta al tope de filas.
static func ordenar(entradas: Array, maximo: int = MAXIMO) -> Array:
	var copia: Array = entradas.duplicate(true)
	copia.sort_custom(_antes)
	while copia.size() > maximo:
		copia.pop_back()
	return copia

static func _antes(a: Dictionary, b: Dictionary) -> bool:
	var ta: float = float(a.get("tamanio", 0.0))
	var tb: float = float(b.get("tamanio", 0.0))
	if not is_equal_approx(ta, tb):
		return ta > tb
	var pa: int = int(a.get("puntos", 0))
	var pb: int = int(b.get("puntos", 0))
	if pa != pb:
		return pa > pb
	return str(a.get("nombre", "")) < str(b.get("nombre", ""))
