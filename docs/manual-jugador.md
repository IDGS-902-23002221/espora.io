# Manual del jugador — ESPORA.io

## Objetivo

Sos una espora que germina al anochecer. Tenés que crecer, sobrevivir a cinco hordas y llegar al amanecer para quedarte con el claro. Si te absorben tres veces, perdés.

## Controles

| Acción | Entrada |
|---|---|
| Mover | `WASD` |
| Girar cámara | mouse |
| Alternar 1.ª / 3.ª persona | `V` |
| Disparar espora | clic izquierdo |
| Pausa / saltar cinemática | `Esc` |
| Elegir skin | menú **Skins** (carrusel) |
| Nombre | campo **Tu nombre** en el lobby (2–16 caracteres) |

La cámara captura el mouse al entrar a la partida. `Esc` la libera y abre la pausa. En la pausa solo hay **Reanudar** y **Abandonar partida**. La cámara no baja del piso; `V` alterna primera persona para seguir jugando cuando el hongo es muy grande.

## Crecimiento

- Cada nutriente normal suma **0.03** de tamaño.
- El nutriente dorado multiplica el crecimiento **×7**.
- El tope de tamaño sube por horda: **4.0 → 5.0 → 6.0 → 7.0 → 8.0**. Al llegar aparece **TAMAÑO MÁXIMO**: los nutrientes dan **+5 puntos extra** y las absorciones **+25**.
- Durante los primeros **10 s** no hay presión. Después, si pasan **4 s sin disparar ni absorber**, empezás a perder **0.02 de tamaño por segundo** (hasta el mínimo 1.0). Disparar o absorber reinicia el contador.
- Cuanto más grande, más lento: la velocidad baja un 8 % por punto de tamaño, con un piso del 60 % de la velocidad base.
- Al absorber a un NPC ganás el **25 %** de su tamaño; el NPC reaparece con el **60 %** de su tamaño y 3 s de cooldown.

## Esporas

Las esporas son el único ataque; las usan el jugador y los NPC.

- Cada objetivo tiene **3 puntos** de daño.
- Un impacto válido vacía un punto.
- Si pasan **4 s** sin impactos, el objetivo regenera 1 punto.
- La espora desaparece a los **3.5 s** si no impacta.
- El jugador dispara cada **0.6 s**; la espora viaja en horizontal a altura fija.
- Solo cuenta si el atacante es al menos **1.10×** el tamaño del objetivo; el escudo ignora impactos.

## Absorción e intentos

- Al vaciar los 3 puntos, el atacante absorbe al objetivo.
- El jugador tiene **3 intentos**. Las **3 hojas verdes** representan su vida actual. Las 3 hojas son tu vida actual: cada hoja aguanta **2 impactos** (medio golpe y hoja completa); con 6 golpes perdés un intento y las 3 hojas vuelven a verde. Si no recibís daño por 4 s, se regenera 1/2 hoja. Al ser absorbido reaparece más chico y queda **5 s invisible**: puede moverse y disparar, no recibe daño de esporas y mantiene la colisión con el piso. Al recibir impactos, el borde de la pantalla se oscurece en rojo.
- Al llegar a 0 intentos, la partida termina en derrota.
- Los NPC también se absorben entre sí y reaparecen.

## Puntaje

| Acción | Puntos |
|---|---|
| Nutriente | 10 |
| NPC absorbido | 100 |
| Horda superada | 250 |

La pantalla de resultado muestra puntaje, NPC absorbidos, tamaño máximo y tiempo.

## Hordas y dificultad

La partida tiene **5 hordas** de 90 s cada una, con 5 s de pausa entre hordas.

| Horda | NPC | Velocidad | Cooldown de disparo | Detección | Tamaño base |
|---|---|---|---|---|---|
| 1 | 10 | 5.0 | 1.6 s | 18 | ×1.0 |
| 2 | 12 | 5.3 | 1.4 s | 20 | ×1.1 |
| 3 | 14 | 5.5 | 1.2 s | 22 | ×1.2 |
| 4 | 16 | 5.8 | 1.0 s | 25 | ×1.3 |
| 5 | 18 | 6.0 | 0.9 s | 28 | ×1.4 |

No hay selector de dificultad: la curva sale de las hordas, los biomas y el tamaño. Los valores viven en `GameConfig` y son provisionales; el detalle está en [balance-propuesta.md](balance-propuesta.md).

## Biomas

- **Bosque Bioluminiscente** (0–25): más nutrientes y NPC más grandes.
- **Pantano de Esporas** (25–45): densidad media y tamaños mixtos.
- **Cueva de Raíces** (45–60): menos nutrientes, NPC chicos y un roamer grande ocasional.

Las especies visuales son Amanita (Bosque), Cubensis (Pantano) y Melena (Cueva). El tinte de cada zona se genera por código.

## Objetos especiales

- **Nutriente dorado:** crecimiento ×7, máximo 1 activo. Aparece después de los primeros 50 s.
- **Espora escudo:** protege de impactos 10 s, máximo 1 activo. Los NPC también pueden tomarla.
- **Espora veloz:** +40 % de velocidad 10 s, máximo 1 activo. Los NPC también pueden tomarla.
- **Cura:** recupera 1 hoja si estás por debajo de 3.
- **Raíz:** frena a los NPC cercanos durante 4 s.
- **Invisibilidad:** 6 s sin que los NPC te detecten.

Después de los primeros **50 s**, la producción total se reparte en **40 % nutrientes azules y 60 % esporas especiales**. Antes de eso solo salen azules.

## Skins

- **Clásico:** Mushnub.
- **Luminaria:** Mushnub Evolved con brillo cyan.
- **Rey:** Mushroom King.
- **Amanita:** el sombrero rojo del bosque.
- **Cubensis:** hongo de pantano, tonos tierra.
- **Melena:** la repisa de la cueva.

Se eligen en el carrusel del menú; solo cambian la apariencia y no persisten entre sesiones.

## Victoria y derrota

- **Victoria:** sobrevivir a la última horda; se muestra el Acto IV — Amanecer y después el resultado en un panel.
- **Derrota:** quedarte sin intentos; se muestra el Acto IV — Oscuridad y después el resultado en un panel.
- **Jugar de nuevo** reinicia la partida; **Volver al lobby** regresa al menú principal. El resultado incluye un campo para escribir tu nombre (vale por la sesión).
- Cada horda tiene refuerzos a 1/3 y 2/3 del tiempo; el HUD muestra el countdown.
- Los NPC de la primera horda arrancan con tu mismo tamaño; en las siguientes escalan.
- Los NPC se atacan entre sí solo si uno es **1.10×** el otro.
- La esquiva de esporas de los NPC sube por horda: **0% → 20% → 40% → 60% → 80%**.
- Al cambiar de horda, los NPC mejoran su puntería y aparece un aviso de 3.5 s.
- Al superar una horda recuperás 1 hoja si estás por debajo de 3.

La apertura se muestra una vez por ejecución; el Acto I aparece al iniciar o reiniciar.

## SmartScreen y antivirus

El `.exe` no está firmado. Si Windows SmartScreen lo bloquea:

1. Clic en **Más información**.
2. Clic en **Ejecutar de todas formas**.

Algunos antivirus pueden marcar el ejecutable de Godot; verificar el archivo y permitirlo solo si confiás en el origen. No hay instalador: es un `.exe` portable.

## Problemas conocidos

- Sin audio y sin multijugador.
- La cámara de `v0.9.0-beta` tenía saltos; v2 corrigió el delta del mouse, el primer movimiento tras foco y el margen del SpringArm.
- Renderer Compatibility; en hardware modesto puede bajar el rendimiento con muchas entidades.
- Las skins no se guardan al cerrar el juego.

## Historia

Los humanos se extinguieron; el micelio despertó y ahora los hongos se disputan el claro. El detalle está en [historia.md](historia.md).

## Consejos

- Empezá por el Bosque: hay más nutrientes y los NPC son más grandes, pero también más peligrosos.
- Usá el tamaño a favor: si sos chico, huí; si sos grande, perseguí.
- Guardá el escudo para las hordas finales.
- El punto de disparo en cruz marca de dónde sale la espora; la espora viaja horizontal.
