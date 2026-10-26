class_name ReglaTamanio
extends RefCounted

enum EstadoTamanio { NEUTRAL, PERSEGUIR, HUIR }

static func proporcion(tamanio_atacante: float, tamanio_objetivo: float) -> float:
	if tamanio_objetivo <= 0.0:
		return 1.0
	return tamanio_atacante / tamanio_objetivo

static func siguiente_estado(estado_actual: EstadoTamanio, proporcion_actual: float, tiempo_en_estado: float) -> EstadoTamanio:
	if tiempo_en_estado < GameConfig.TIEMPO_MIN_ESTADO:
		return estado_actual

	match estado_actual:
		EstadoTamanio.NEUTRAL:
			if proporcion_actual >= GameConfig.UMBRAL_ATAQUE_ENTRADA:
				return EstadoTamanio.PERSEGUIR
			if proporcion_actual <= GameConfig.UMBRAL_HUIDA_ENTRADA:
				return EstadoTamanio.HUIR
			return EstadoTamanio.NEUTRAL
		EstadoTamanio.PERSEGUIR:
			if proporcion_actual < GameConfig.UMBRAL_ATAQUE_SALIDA:
				if proporcion_actual <= GameConfig.UMBRAL_HUIDA_ENTRADA:
					return EstadoTamanio.HUIR
				return EstadoTamanio.NEUTRAL
			return EstadoTamanio.PERSEGUIR
		EstadoTamanio.HUIR:
			if proporcion_actual > GameConfig.UMBRAL_HUIDA_SALIDA:
				if proporcion_actual >= GameConfig.UMBRAL_ATAQUE_ENTRADA:
					return EstadoTamanio.PERSEGUIR
				return EstadoTamanio.NEUTRAL
			return EstadoTamanio.HUIR

	return estado_actual
