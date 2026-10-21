# ESPORA.io — Propuesta de balance (PROVISIONAL)

> **Todos los valores de este documento son una propuesta inicial y van a cambiar.**
> Se calibran jugando. Cambiar un valor significa editar `GameConfig` (y actualizar este documento), **nunca la lógica**.
> Los nombres en `UPPER_SNAKE` son los nombres sugeridos para las constantes de `GameConfig`.
> Unidades: distancias en unidades de Godot, tiempos en segundos, tamaño como factor de escala lineal.

Lo único **congelado** de aquí es lo que ya está en `AGENTS.md` sección 2: 3 impactos para absorber, esporas que expiran a 3.5 s, y regla de tamaño. Todo lo demás es ajustable.

---

## 1. Regla de tamaño, empate e histéresis

Se define una sola proporción: `proporcion = tamaño_atacante / tamaño_objetivo`.

**Un solo juego de umbrales para todo** (IA y daño), para que haya una única fuente de verdad:

| Constante | Valor propuesto | Significado |
|---|---|---|
| `UMBRAL_ATAQUE_ENTRADA` | 1.10 | El NPC empieza a perseguir y disparar cuando es al menos 10 % más grande |
| `UMBRAL_ATAQUE_SALIDA` | 1.05 | Una vez persiguiendo, solo deja de hacerlo si baja de 1.05 |
| `UMBRAL_HUIDA_ENTRADA` | 0.90 | El NPC empieza a huir cuando es al menos 10 % más chico |
| `UMBRAL_HUIDA_SALIDA` | 0.95 | Una vez huyendo, solo deja de hacerlo si sube de 0.95 |
| `TIEMPO_MIN_ESTADO` | 1.0 | Segundos mínimos en un estado antes de poder cambiar (segundo seguro contra oscilación) |

**Zona neutral (empate):** entre 0.90 y 1.10 nadie persigue ni huye. El NPC deambula y **no dispara**. Las esporas de un atacante que no supera el umbral no cuentan para absorber. Responde la pregunta "¿qué pasa si somos del mismo tamaño?": **nada, hay tregua**, y el juego te empuja a crecer un poco más que el rival para poder cazarlo.

Por qué histéresis: sin ella, un NPC con proporción 1.0 ± ruido cambiaría de huir a perseguir todos los frames. Con entrada y salida distintas, el estado se mantiene hasta que el cambio de tamaño es real.

---

## 2. Tamaño y crecimiento

| Constante | Valor propuesto | Notas |
|---|---|---|
| `TAMANIO_INICIAL` | 1.0 | Jugador al empezar |
| `TAMANIO_MAXIMO` | 6.0 | Tope para el jugador y los NPC |
| `CRECIMIENTO_NUTRIENTE` | 0.03 | Aprox. 33 nutrientes para duplicar el tamaño |
| `MULT_NUTRIENTE_DORADO` | 3.0 | Ya definido en el GDD (triplica) |
| `FRACCION_ABSORCION` | 0.25 | El que absorbe gana el 25 % del tamaño del absorbido |
| `FRACCION_REAPARICION` | 0.60 | El absorbido reaparece con 60 % de su tamaño, nunca menos de `TAMANIO_INICIAL` |
| `COOLDOWN_REAPARICION_JUGADOR` | 3.0 | Coincide con la cuenta regresiva 3-2-1 del storyboard 4 |
| `COOLDOWN_REAPARICION_NPC` | 2.0 | |

---

## 3. Velocidad

La velocidad baja un poco al crecer (convención de los .io) para que ser grande tenga un costo.

| Constante | Valor propuesto |
|---|---|
| `VELOCIDAD_BASE_JUGADOR` | 6.0 |
| `PENALIZACION_VELOCIDAD_POR_TAMANIO` | 0.08 por cada unidad de tamaño sobre 1.0 |
| `VELOCIDAD_MINIMA_FRACCION` | 0.60 (la velocidad nunca baja de 60 % de la base) |
| `MULT_VELOCIDAD_ESPORA_VELOZ` | 1.40 |
| `DURACION_ESPORA_VELOZ` | 4.0 |

Fórmula sugerida: `velocidad = BASE * max(VELOCIDAD_MINIMA_FRACCION, 1.0 - PENALIZACION * (tamaño - 1.0))`.

Si los NPC fueran más rápidos que el jugador desde el inicio, no se podría huir. Por eso en las primeras hordas son un poco más lentos (ver sección 7).

---

## 4. Esporas y daño

| Constante | Valor propuesto | Notas |
|---|---|---|
| `IMPACTOS_PARA_ABSORBER` | 3 | **Congelado** |
| `VIDA_ESPORA` | 3.5 | **Congelado** |
| `VELOCIDAD_ESPORA` | 14.0 | Alcance efectivo aprox. 49 unidades, menor que el diámetro de la arena |
| `COOLDOWN_DISPARO_JUGADOR` | 0.6 | |
| `REGENERACION_PUNTO_DAÑO` | 4.0 | Segundos sin recibir impactos para recuperar 1 punto (propuesta, ver decisiones abiertas) |
| `DURACION_ESPORA_ESCUDO` | 5.0 | |

**Indicador de daño (3 puntos):**
- Punto lleno: color cian. Punto vaciado: gris oscuro.
- Al recibir un impacto, el punto parpadea en rojo unos 0.2 s y queda vacío.
- Cuando los 3 están vacíos, el hongo es absorbido.

---

## 5. Mapa, biomas y NPC

Arena circular, radio `RADIO_MAPA = 60`.

| Bioma | Anillo (distancia al centro) | Tamaño de aparición de NPC | Nutrientes |
|---|---|---|---|
| Bosque Bioluminiscente | 0 – 25 | 1.5 – 2.5 | densidad x2 |
| Pantano de Esporas | 25 – 45 | 0.8 – 1.8 | densidad x1 |
| Cueva de Raíces | 45 – 60 | 0.5 – 1.0 | densidad x0.5 |

| Constante | Valor propuesto | Notas |
|---|---|---|
| `NUTRIENTES_ACTIVOS_MAX` | 100 | Tope simultáneo; ajustar con el profiler |
| `INTERVALO_REAPARICION_NUTRIENTE` | 0.5 | Un nutriente nuevo cada 0.5 s hasta el tope |
| `INTERVALO_NUTRIENTE_DORADO` | 30 – 45 | Máximo uno activo |
| `INTERVALO_ESPORA_ESCUDO` / `INTERVALO_ESPORA_VELOZ` | 40 – 60 | Máximo uno activo de cada tipo |
| `NPC_MAX_ABSOLUTO` | 24 | Tope duro; **medir rendimiento en hardware sin GPU dedicada antes de subirlo** |

---

## 6. Hordas (propuesta pendiente de confirmación)

La noche se divide en **5 hordas de 90 s** (aprox. 7.5 min, dentro del objetivo de 5–10 min), con 5 s de pausa entre una y otra. Al terminar la horda 5 amanece y la partida termina. Como el jugador no tiene vidas, el fracaso no es un game over: es reaparecer más pequeño y perder tiempo y tamaño. El resultado final se mide por tamaño máximo, absorciones y tiempo.

| Constante | Horda 1 | Horda 2 | Horda 3 | Horda 4 | Horda 5 |
|---|---|---|---|---|---|
| `DURACION_HORDA` | 90 | 90 | 90 | 90 | 90 |
| `NPC_POR_HORDA` | 12 | 14 | 16 | 18 | 20 |
| `VELOCIDAD_NPC` | 5.0 | 5.3 | 5.5 | 5.8 | 6.0 |
| `COOLDOWN_DISPARO_NPC` | 1.2 | 1.05 | 0.9 | 0.8 | 0.7 |
| `RADIO_DETECCION_NPC` | 18 | 20 | 22 | 25 | 28 |
| `MULT_TAMANIO_APARICION` | 1.0 | 1.1 | 1.2 | 1.3 | 1.4 |

Las hordas escalan **parámetros**, no reglas: la regla de tamaño no cambia nunca.

---

## 7. Cómo se calibra

1. Probar la horda 1 hasta que se sienta justa.
2. Cambiar **un valor a la vez** en `GameConfig` y anotar el efecto en el ticket correspondiente.
3. Si un cambio implica tocar lógica y no solo un número, es señal de que falta exponer ese valor en `GameConfig`.
