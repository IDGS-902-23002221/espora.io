class_name Crecimiento
extends RefCounted

static func crecer(tamanio_actual: float) -> float:
	return minf(tamanio_actual + GameConfig.CRECIMIENTO_NUTRIENTE, GameConfig.TAMANIO_MAXIMO)

static func velocidad_por_tamanio(tamanio: float, base: float) -> float:
	var factor: float = 1.0 - GameConfig.PENALIZACION_VELOCIDAD_POR_TAMANIO * (tamanio - GameConfig.TAMANIO_INICIAL)
	return base * maxf(factor, GameConfig.VELOCIDAD_MINIMA_FRACCION)
