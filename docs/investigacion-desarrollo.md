# ESPORA.io — Investigación: desarrollo con Godot, vibe coding y ciclo DevOps

Resumen de la investigación previa al backlog. Referencia para el agente; si algo contradice `AGENTS.md` o un ticket, gana el ticket.

## 1. Cómo se desarrolla un juego como ESPORA

Ciclo estándar: preproducción, prototipo, vertical slice, pre-alpha, alpha (feature complete: jugable de principio a fin pero sin assets finales), beta (optimización y pulido) y gold master.

En un arcade tipo .io se prueba primero el loop central (moverse, comer, crecer, huir o perseguir según el tamaño) y el contenido llega después. Aplicado a ESPORA:

- **Prototipo:** hongo, nutrientes, crecimiento y un NPC con la regla de tamaño.
- **Vertical slice:** un bioma completo con esporas, HUD con los 3 puntos de daño y respawn con cooldown.
- **Alpha:** 3 biomas, objetos especiales, skins, menús y hordas.
- **Beta:** balance, audio y rendimiento.
- **Gold:** build final entregable.

## 2. Vibe coding con Godot

- Los archivos de Godot (`.gd`, `.tscn`, `.tres`, `project.godot`) son texto, así que Git y el agente trabajan bien con ellos.
- **El agente escribe scripts; las escenas se arman en el editor** (o con el MCP de Godot, usando solo sus herramientas). Editar `.tscn` a mano puede corromper la escena, y lo que se configura en el Inspector (`@export` de nodos, capas de colisión, Input Map) el agente no lo ve. Error típico: variable en `Nil` por no asignar un nodo en el Inspector.
- Cada ticket lleva sus **pasos manuales en editor** como primera fase de "Qué resta".
- `AGENTS.md` en la raíz con versión, renderer, convenciones, estructura, qué no tocar y comandos de verificación.
- Los números de balance viven en `GameConfig`.
- Sesiones cortas, un ticket por sesión.
- El agente no puede juzgar el "feel": cada ticket cierra con una prueba manual (F5) con pasos concretos.

## 3. Herramientas

Por defecto, todo es nativo de Godot: editor, GDScript tipado, escenas, Input Map, `CharacterBody3D`, `Area3D`, `Timer`, `Tween`, partículas, buses de audio, depurador con profiler y monitores, export presets.

- **Versión:** Godot 4.7.2-stable.
- **Renderer:** Compatibility. La máquina de desarrollo no tiene GPU dedicada, y ese renderer está pensado para hardware de gama baja (OpenGL ES 3.0).
- **Excepciones externas justificadas:**
  - **Git + GitHub:** rollback, ramas por ticket y base de CI. Ignorar `.godot/`. El editor genera `.gitignore` y `.gitattributes` desde Project > Version Control.
  - **gdUnit4 (addon):** Godot no trae test runner propio. Se instala desde AssetLib en el editor y se activa en Project Settings > Plugins.
  - **GitHub Actions (fase 2):** compilar, probar y exportar en la nube sin cargar la laptop. Solo cuando ya existan pruebas.
  - **MCP de Godot:** instalado por el usuario; documentar y justificar en el ticket de setup.
- **Descartadas por ahora:** Blender, Krita y Audacity (primitivas + shader de flat shading, UI con nodos `Control`, audio con placeholders).

## 4. Ciclo DevOps aplicado

El juego es offline y de un solo jugador, así que "operar y monitorear" se reinterpreta como playtest.

**Plan → Code → Verify → Test → Package → Distribute → Playtest → Plan**

1. **Plan (Notion):** el GDD se parte en épicas; cada ticket es una mecánica verificable con criterio de aceptación jugable. Épicas provisionales: Setup, Jugador y cámara, Mundo y crecimiento, Esporas y combate, NPCs, Biomas, UI y estados, Hordas, Audio y juice, Pulido y release.
2. **Code (OpenCode + editor de Godot):** una rama por ticket (`ticket-000-X`); el usuario prepara escenas y nodos, el agente escribe scripts solo en "Archivos a tocar", con commits pequeños.
3. **Verify (local, headless):** `tools/verify.ps1` con tres pasos: `--import`, `--check-only --script` por cada `.gd`, y carga de la escena principal con `--quit-after`.
4. **Test:**
   - Capa A, lógica pura con gdUnit4: regla de tamaño, histéresis, contador de impactos, expiración de esporas, crecimiento, respawn.
   - Capa B, pocos tests de escena (con cuidado: en headless el input es problemático y sin GPU las pruebas son lentas).
   - Capa C, playtest manual por ticket.
5. **Package:** merge a `main` solo con Verify y Test en verde; tags (`v0.1.0-prototipo`); export con `godot --headless --path <proyecto> --export-release <preset> <archivo>`; se commitea `export_presets.cfg` sin credenciales.
6. **Distribute:** GitHub Releases con el zip y el changelog.
7. **Playtest y Monitor:** sesiones de 5 a 10 minutos; FPS con los monitores del depurador, cuellos de botella con el profiler según el número de NPC, y log de tiempo de supervivencia, tamaño máximo y causa de muerte. El feedback se convierte en tickets nuevos.

## 5. Riesgos propios de ESPORA

- **IA de NPC:** la arena es abierta y circular; empezar con steering simple (acercarse o alejarse según el tamaño, evitar el borde). `NavigationAgent3D` solo si luego hay obstáculos.
- **Rendimiento sin GPU dedicada:** número de NPC y esporas configurable y medido con el profiler.
- **Contexto del agente:** un ticket por sesión y pasar solo los tickets relevantes.
- **Conflictos en escenas:** si solo el usuario (o el MCP) edita `.tscn`, casi no hay conflictos de merge.

## Fuentes

- Documentación de Godot, línea de comandos: https://docs.godotengine.org/en/4.4/tutorials/editor/command_line_tutorial.html
- Documentación de Godot, control de versiones: https://docs.godotengine.org/en/4.4/tutorials/best_practices/version_control_systems.html
- Documentación de Godot, arquitectura de renderers: https://docs.godotengine.org/en/4.7/engine_details/architecture/internal_rendering_architecture.html
- gdUnit4, instalación: https://mikeschulze.github.io/gdUnit4/first_steps/install
- gdUnit4, integración continua: https://mikeschulze.github.io/gdUnit4/faq/ci
- gdUnit4Net, problemas de CI en headless: https://github.com/godot-gdunit-labs/gdUnit4Net/discussions/350
- gdmutant (herramienta comunitaria; menciona que Godot no trae test runner): https://pypi.org/project/gdmutant/0.1.1/
- Golem MCP (ejemplo de bloqueo de edición directa de `.tscn`): https://pypi.org/project/golem-mcp/
- Fases de desarrollo de videojuegos: https://rocketbrush.com/blog/game-development-process-guide
- Pipeline de desarrollo de videojuegos: https://techpro.smu.edu/blog/how-video-games-are-made-the-game-development-process
- Godot 4.7.2: https://gamedev.net/news/5172-godot-engine-472-stable-released/
