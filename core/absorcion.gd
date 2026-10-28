class_name Absorcion
extends RefCounted

# Al absorber, el atacante gana una fraccion del tamano del absorbido, con tope.
# No reusa Crecimiento.crecer porque esa suma un monto fijo (nutrientes), no una fraccion.
static func crecimiento_por_absorcion(tamanio_atacante: float, tamanio_absorbido: float) -> float:
	if tamanio_absorbido <= 0.0:
		return tamanio_atacante
	var crecimiento: float = tamanio_absorbido * GameConfig.FRACCION_ABSORCION
	return minf(tamanio_atacante + crecimiento, GameConfig.TAMANIO_MAXIMO)

# El absorbido reaparece con una fraccion de su tamano, nunca por debajo del inicial.
static func tamanio_reaparicion(tamanio_absorbido: float) -> float:
	return maxf(tamanio_absorbido * GameConfig.FRACCION_REAPARICION, GameConfig.TAMANIO_INICIAL)
