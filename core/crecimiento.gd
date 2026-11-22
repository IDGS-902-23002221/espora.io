class_name Crecimiento
extends RefCounted

static func crecer(tamanio_actual: float, multiplicador: float = 1.0, maximo: float = GameConfig.TAMANIO_MAXIMO) -> float:
	var aumento: float = GameConfig.CRECIMIENTO_NUTRIENTE * multiplicador
	return minf(tamanio_actual + aumento, maximo)

static func velocidad_por_tamanio(tamanio: float, base: float) -> float:
	var factor: float = 1.0 - GameConfig.PENALIZACION_VELOCIDAD_POR_TAMANIO * (tamanio - GameConfig.TAMANIO_INICIAL)
	return base * maxf(factor, GameConfig.VELOCIDAD_MINIMA_FRACCION)
