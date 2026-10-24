# AGENTS.md — ESPORA.io

Reglas del proyecto para agentes de código (OpenCode). Léelo completo al inicio de cada sesión.
Si algo de aquí contradice un ticket, **gana el ticket**; si contradice una regla congelada de diseño, **detente y pregunta**.

---

## 1. Qué es el proyecto

ESPORA.io es un juego **3D, un solo jugador, estilo .io**, hecho en **Godot**. El jugador controla un hongo que crece absorbiendo nutrientes y esquivando o cazando a hongos NPC. Beta sin multijugador.

Origen: proyecto de la materia Creación de Videojuegos (portafolio con GDD, storyboard y plan de trabajo ya entregados). Este repo es la implementación.

**Esencia .io (no negociable):** el **tamaño relativo** decide quién persigue y quién huye, y eso se recalcula en tiempo real durante toda la partida.

---

## 2. Reglas de diseño CONGELADAS

No cambiarlas, reinterpretarlas ni "mejorarlas" sin un ticket que lo pida explícitamente.

- **Regla de tamaño (IA de NPC):** si el NPC es más grande que su objetivo, lo persigue y le dispara esporas; si es más chico, huye al detectarlo. Es una sola regla universal, **no hay "tipos" de NPC con personalidad fija** (pasivo, territorial, cazador quedaron descartados).
- **Especies = solo identidad visual.** Amanita, Cubensis, Melena y Luminaria no cambian el comportamiento.
  - Amanita → Bosque Bioluminiscente (población que nace más grande en promedio).
  - Cubensis → Pantano de Esporas (tamaños mixtos).
  - Melena → Cueva de Raíces (población que nace más pequeña, con evento ocasional de un roamer grande).
  - Luminaria → skin desbloqueable del jugador, no NPC de zona.
- **Esporas:** único ataque del juego, lo usan el jugador y los NPC. **3 impactos seguidos** sobre el mismo objetivo lo absorben. "Seguidos" significa que entre un impacto y el siguiente pasan menos de 4 s; si pasan 4 s sin recibir impactos, el objetivo regenera 1 punto de daño. Las esporas que no impactan desaparecen a los **3.5 s**.
- **Absorción:** quien absorbe crece; el absorbido reaparece en otro punto del mapa **más pequeño** y con **cooldown breve**.
- **Mapa:** una sola arena circular con 3 biomas (Bosque Bioluminiscente al centro, Pantano de Esporas en medio, Cueva de Raíces en los bordes). Partidas cortas (5–10 min), sin niveles secuenciales.
- **Objetos especiales:** nutriente dorado (triplica el crecimiento), espora escudo (protege temporalmente de impactos), espora veloz (más velocidad unos segundos).
- **Skins:** cosméticas, sin efecto en gameplay.
- **Sin multijugador ni networking** en esta beta. No escribir código de red.
- **Estilo visual:** low-poly construido con primitivas de Godot (cilindro de cuerpo, esfera o cono de sombrero, ojos como óvalos planos, sin brazos ni boca).

### Decisiones tomadas por el usuario

- **El jugador NO tiene vidas ni game over por daño.** Si es absorbido, reaparece más pequeño con cooldown (storyboard 4).
- **Indicador de daño:** 3 puntos en el HUD que cambian de color o se vacían con cada impacto de espora recibido (representan los 3 impactos que absorben al objetivo).
- **Ventana de impactos:** cada impacto reinicia un temporizador de 4 s; si vence sin nuevos impactos, el objetivo recupera 1 punto. Se absorbe cuando los 3 puntos están vacíos.
- **Los NPC también muestran sus 3 puntos** sobre la cabeza, con las mismas reglas.
- **El tamaño del jugador se conserva entre hordas.**

### Propuestas pendientes de confirmación (tratar como PROVISIONALES)

- **Hordas:** la partida se divide en hordas y cada horda aumenta las capacidades de los NPC. Esto también define cómo termina la partida (sobrevivir hasta el "amanecer", al final de la última horda).
- **Empate de tamaño e histéresis:** zona neutral entre proporciones de tamaño 0.90 y 1.10, con umbrales de entrada y salida distintos para que la IA no oscile.
- **Valores numéricos de balance:** propuesta inicial en `docs/balance-propuesta.md`. **Son provisionales y van a cambiar.** Viven en `GameConfig`, nunca en la lógica. No los trates como requisitos ni los "corrijas" por tu cuenta.

### Decisiones abiertas (NO asumir; preguntar o dejar para un ticket de diseño)

- Ninguna por ahora. Si surge una duda de diseño que no esté cubierta en este archivo, pregunta antes de asumir.

---

## 3. Stack y entorno

- **Motor:** Godot **4.7.2-stable** (official, build `ed1daf0bf`), versión fijada. No actualizar sin ticket.
- **Renderer:** **Compatibility** (la máquina de desarrollo no tiene GPU dedicada; el rendimiento es una restricción real).
- **Lenguaje:** GDScript con **tipado estático**.
- **SO / terminal:** Windows con PowerShell. Repos de la escuela en `C:\PERSONAL\utl\`.
- **Ejecutable de Godot:** variable de entorno `GODOT_BIN`. Si no existe, pide la ruta; no la adivines.
- **Repo:** https://github.com/IDGS-902-23002221/espora.io.git. La raíz del repo es la raíz del proyecto de Godot (`project.godot` en la raíz). Ruta local: `C:\Godot\espora.io`.
- **Estado inicial:** el repo es nuevo; puede estar vacío o solo con el proyecto base. Verificar el contenido real antes de asumir que existe algún script.

### Herramientas

**Por defecto, solo Godot.** Una herramienta externa entra únicamente si es muy necesaria y se justifica por escrito en el ticket.

| Estado | Herramienta | Nota |
|---|---|---|
| Aprobada | Git + GitHub | Control de versiones y base de CI |
| Aprobada | gdUnit4 6.2.0 (addon versionado en el repo) | Godot no trae test runner propio. Instalado desde Asset Store y activado; se versiona en `addons/gdUnit4/` |
| Instalada por el usuario | Godot Editor MCP (servidor `godot-mcp` 2026.10.20, addon 2026.10.20) | Puente con el editor. Se versiona en `addons/godot_mcp/` (decisión del ticket 000.1). Toolsets aprobados: `core` e `inspection`, ambos de solo lectura; no se activan toolsets mutantes sin aprobación |
| Fase 2 | GitHub Actions | Solo cuando ya existan pruebas; no bloquea el arranque |
| Descartada por ahora | Blender, Krita, Audacity | Modelos con primitivas + shader de flat shading, UI con nodos `Control`, audio con placeholders |

No agregar addons, plugins ni dependencias sin ticket.

---

## 4. Qué puede y qué NO puede tocar el agente

- **Escribe y edita:** scripts `.gd`, tests, scripts de `tools/`, documentación.
- **NO edita a mano:** archivos `.tscn`, `.tres`, `project.godot`, `export_presets.cfg`. Se pueden corromper y el agente no ve el editor.
- **Con el MCP de Godot conectado:** las escenas y nodos se modifican solo con sus herramientas (nunca editando el texto del archivo) y únicamente cuando el ticket lo pide. Todo lo que el MCP no cubra sigue siendo paso manual del usuario.
- **Lo que se configura en el Editor lo hace el usuario.** Si un ticket lo requiere, el agente lo deja como **pasos manuales numerados** al inicio de "Qué resta". Ejemplos:
  - asignar nodos en variables `@export` en el Inspector (error típico: `Nil` por no asignar la cámara);
  - crear acciones en el Mapa de entrada;
  - nombrar capas de colisión y asignar `collision_layer` / `collision_mask`;
  - agregar un Autoload;
  - cambiar el renderer, la metadata de versión o los plugins activos de `project.godot` (siempre desde el editor, nunca editando el archivo);
  - armar la estructura de nodos de una escena.
- Solo se toca lo listado en **"Archivos a tocar"** del ticket. Lo de **"No tocar"** es intocable.

---

## 5. Convenciones de código (GDScript)

- **Indentación con TABS, nunca espacios.** Mezclarlos rompe el script.
- Tipado estático siempre: `var vida: int = 3`, `func crecer(cantidad: float) -> void:`.
- Nombres de variables y funciones en **español `snake_case`**, como el código existente (`modo_fps`, `perder_vida`). Constantes en `UPPER_SNAKE`. API de Godot en inglés tal cual.
- Comunicación entre nodos por **señales**; evitar rutas `get_node("../../X")` frágiles. Referencias con `@onready` o `@export`.
- **Composición sobre herencia:** componentes pequeños reutilizables (por ejemplo salud o crecimiento) en vez de una clase gigante por entidad.
- **Autoload `GameManager`** solo para estado global (estado de partida, puntaje). Nada más.
- **Cero números mágicos:** todo valor de balance vive en `GameConfig`. Los valores iniciales están en `docs/balance-propuesta.md` y son provisionales; si un valor cambia, se cambia en `GameConfig` y en ese documento, nunca en la lógica.
- **Separar lógica de nodos:** reglas puras (regla de tamaño, contador de impactos, expiración de esporas, crecimiento) en scripts testeables sin depender del árbol de escena.
- Comentarios solo donde el "por qué" no es obvio. Sin código muerto ni `print` de depuración olvidados.

### Estructura de carpetas (por feature)

```
res://
├── core/        # GameManager, GameConfig
├── entities/    # player/, npc/, spore/, nutrient/
├── world/       # biomas, spawn
├── ui/          # menú, HUD, pausa, skins
├── data/        # recursos de datos
├── audio/
├── tests/       # gdUnit4
└── tools/       # verify.ps1 y utilidades
```

---

## 6. Verificación antes de dar algo por hecho

Un ticket **no se cierra** sin verificar. Comandos (a automatizar en `tools/verify.ps1` durante el ticket de setup):

```powershell
# 1. Importar recursos
& $env:GODOT_BIN --headless --path . --import

# 2. Validar sintaxis de cada script (repetir por cada .gd)
& $env:GODOT_BIN --headless --path . --check-only --script res://ruta/al_script.gd

# 3. Cargar la escena principal unos frames para detectar errores de carga
& $env:GODOT_BIN --headless --path . --quit-after 60

# 4. Pruebas unitarias (este comando EJECUTA los tests, no instala nada).
#    gdUnit4 6.2.0 corre todos los tests por defecto; --run-tests ya no existe.
#    En headless requiere --ignoreHeadlessMode.
& $env:GODOT_BIN --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode
```

- Los tests automáticos cubren **lógica pura**. No depender de render ni de input en modo headless (es lento y poco confiable sin GPU).
- Lo que no se puede automatizar (cámara, sensación de movimiento, comportamiento de la IA) se cierra con una **prueba manual (F5)** descrita en el ticket con pasos concretos. El agente no declara "se siente bien": reporta qué debe probar el usuario.
- Reportar resultados reales (qué comando, qué salida), sin especular.

---

## 7. Rendimiento

- Desarrollar y medir sobre Compatibility en hardware modesto.
- Cantidad de NPC y de esporas simultáneas **configurables** y con tope; medir con el profiler y los monitores del depurador antes de subirlos.
- Evitar asignaciones por frame en `_process` / `_physics_process`; preferir señales y temporizadores.
- Partículas baratas y pocas; medir antes de optimizar.
- IA de NPC: empezar con **steering simple** (acercarse o alejarse según el tamaño, evitar el borde del mapa). Usar `NavigationAgent3D` solo si aparecen obstáculos; hornear el navmesh es paso manual en el editor.

---

## 8. Git

- Una rama por ticket: `ticket-000-X`. Commits pequeños con mensaje `TICKET 000.X: qué se hizo`.
- `main` solo recibe merges con la verificación en verde.
- Ignorar `.godot/` (caché). `.gitattributes` con LF.
- `export_presets.cfg` se commitea (CI lo necesita), **sin credenciales dentro**.
- Nunca commitear secretos (API keys, tokens de Notion o de Anthropic).
- Sin `push --force`. Versionado con tags (`v0.1.0-prototipo`).

---

## 9. Flujo de tickets en Notion

Los tickets viven en Notion (vía MCP). **Nunca trabajar sin ticket.**

El TICKET 000 de **ESPORA.io** es esta página: https://app.notion.com/p/TICKET-000-ESPORA-io-400fd5d7f03f80fba1e5eeca7d4f1f40 En Notion puede haber otros TICKET 000 de otros proyectos: **no leerlos ni modificarlos**.

### Abrir un ticket
1. Página hija del **TICKET 000**, numerada `000.X` (o `000.X.Y` si se subdivide).
2. Título: `TICKET 000.X — [título descriptivo]`.
3. Encabezado fijo: **Ticket padre** (mención al TICKET 000), **Ticket relacionado** (páginas 01/02/03 que apliquen), **Creado** (fecha), **Cerrado** (`(abierto)` o `(no cerrado)`), **Autor**.
4. Cuerpo con la plantilla exacta, 4 secciones:
   - **Qué se tenía que hacer:** 1–2 oraciones, el objetivo.
   - **Qué se resolvió:** al abrir, contexto y decisiones ya tomadas, o `(Nada aún)`.
   - **Qué quedó a la mitad:** al abrir, `Nada. El ticket es nuevo.`
   - **Qué resta:** pendientes concretos. **Antes de redactarla, cruzarla contra los tickets existentes** para no repetir lo ya resuelto. Organizar en fases con checkboxes (prerrequisitos manuales → script → verificación → cierre).
5. Campos extra obligatorios: **Archivos a tocar** y **No tocar**, para leer solo lo necesario.
6. Secciones libres según haga falta: Decisiones previas, Riesgos, Notas de recorte (qué se aparca y su deuda).

### Cómo se trabaja
- Cada sesión genera tickets con este formato; si un ticket crece, se divide en hijo numerado.
- Deben leerse solos: decisiones con justificación, bugs con **causa raíz**, resultados concretos si se probó, solo fragmentos clave (**nunca código completo**), sin especulaciones.
- Una sesión = un ticket. Tickets chicos: una mecánica verificable.
- Al retomar: leer los tickets relevantes y cruzarlos **antes** de proponer el siguiente paso.

### Cómo se cierra
1. **Qué se resolvió** con detalle técnico real (archivos, commits, resultados de verificación).
2. **Qué quedó a la mitad** con qué quedó y su causa exacta, o `(Nada.)`.
3. **Qué resta** se reduce a lo que sigue en otro ticket, o `(Nada)`. El campo **Cerrado** pasa a la fecha (`AAAA-MM-DD`).
4. **El TICKET 000 (padre) no se edita por cada cierre.** En su lugar se agrega al final una sección de avance fechada.

---

## 10. Reglas de conducta del agente

- Comunicación y tickets en **español**.
- Al iniciar una sesión: leer este archivo, leer el ticket asignado y los relacionados, **resumir lo entendido y esperar confirmación** antes de modificar nada si hay ambigüedad.
- No inventar requisitos ni valores. Si falta una decisión, listarla como duda.
- No ampliar el alcance del ticket. Lo que surja de más se anota como ticket nuevo o en "Notas de recorte".
- No tocar tickets cerrados salvo por el procedimiento de cierre.
- Admitir un error y arreglarlo; reportar los fallos tal cual, sin maquillar resultados de verificación.
