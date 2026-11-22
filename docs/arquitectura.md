# Arquitectura — ESPORA.io v2

## Stack

- **Godot 4.7.2-stable**, GDScript con tipado estático.
- Renderer **Compatibility** (GL), pensado para hardware modesto.
- **gdUnit4 6.2.0** para tests; **Godot Editor MCP** para inspección del editor.
- Sin networking, sin audio y sin persistencia fuera de la sesión.

## Autoload y clases puras

- **`GameManager`** (autoload): estado de partida (`MENU`, `JUGANDO`, `PAUSADO`, `TERMINADA`), `hordas`, `progreso`, `victoria`, `skin_jugador`, `apertura_mostrada`. Solo estado global.
- **`GameConfig`**: constantes de balance (tamaños, velocidades, intervalos, hordas, biomas). No es autoload; se accede como `GameConfig.NOMBRE`. No se cambian valores en la lógica.
- Clases puras (`class_name`, `RefCounted`): `Hordas`, `Puntaje`, `Bioma`, `Crecimiento`, `Absorcion`, `ReglaTamanio`, `PuntosDano`, `ResultadoPartida`, `Cartelas`, `Especies`. Se testean sin árbol de escena.

## Escenas

- `world/arena.tscn` (escena principal): piso, luces, `Jugador`, `Nutrientes`, `HUD`, `ControladorPartida`, `PantallaResultado`, `WorldEnvironment`.
- `entities/player/player.tscn`: `CharacterBody3D`, cápsula, `Visual`, `SpringArm3D` + cámara, `PuntoDisparo`, `LuzJugador`.
- `entities/npc/npc.tscn`: `CharacterBody3D`, cápsula, `Visual`, `Label3D`.
- `entities/spore/spore.tscn`: `Area3D` con esfera de colisión y malla.
- `entities/nutrient/nutrient.tscn`: `Area3D` que crece al jugador o NPC.
- `ui/hud.tscn`, `ui/pantalla_resultado.tscn`: HUD y resultado.
- UI por código: `menu_principal.gd`, `menu_skins.gd`, `menu_pausa.gd`, `pantalla_carga.gd`, `cinematica.gd`.

Las escenas y nodos se editan desde el editor; el agente no edita `.tscn` a mano.

## Capas de física

Definidas en `project.godot`:

1. `jugador`
2. `npc`
3. `entorno`
4. `nutriente`
5. `espora`

La espora del jugador golpea NPC; la del NPC golpea jugador y otros NPC. El tirador se ignora.

## Flujo de partida

1. `arena.tscn` carga y `ControladorPartida._ready()` arma menús, cinemática, tinte y powerups.
2. Si `GameManager` no está jugando y `apertura_mostrada` es false: cinemática de apertura → menú.
3. **Iniciar partida** → `GameManager.iniciar_partida()`; pantalla de carga 0.8 s.
4. Al terminar la carga: Acto I → juego (HUD visible, mouse capturado).
5. `ControladorPartida._process()` avanza tiempo de `Puntaje` y `Hordas`; los eventos generan olas.
6. Al terminar la última horda: Acto IV → resultado de victoria.
7. Si el jugador pierde sus 3 intentos: Acto IV → resultado de derrota.
8. **Jugar de nuevo** reinicia y recarga la escena; **Abandonar** vuelve al menú.

`GameManager` conserva `apertura_mostrada` para que la apertura no se repita al recargar la escena.

## Hordas y puntaje

- `Hordas` avanza un reloj y devuelve eventos (`FIN_HORDA`, `INICIO_HORDA`, `FIN_PARTIDA`); no conoce nodos.
- `GameConfig.HORDAS` define duración, NPC, velocidad, cooldown, detección y multiplicador de tamaño.
- `Puntaje` acumula puntos, intentos, absorbidos, tamaño máximo y tiempo; emite señales para el HUD y la derrota.
- `ResultadoPartida` arma los textos de la pantalla de resultado.

## UI y cinemática

- `ControladorPartida` instala menús y cinemática por código; no hay `.tscn` nuevos.
- `Cinematica` muestra secuencias de beats con fondo animado (`CPUParticles2D`), fades y avance automático; botón/Esc para saltar.
- `Cartelas` guarda los textos de apertura, Acto I y Acto IV (victoria/derrota). El Acto IV define tinte y color de partículas.
- El HUD se oculta en menús, pausa, cinemática y resultado.

## Tests

- Suite **gdUnit4**: 155 tests, 22 suites; cubre configuración, biomas, crecimiento, absorción, esporas, hordas, puntaje, cámara, menús, skins, cartelas y jugador.
- La lógica pura se testea sin render ni input.
- `tools/verify.ps1`: import, check-only, escena principal y gdUnit4.
- Comando manual:

```powershell
& $env:GODOT_BIN --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests
```

## Convenciones

- Tabs, tipado estático, nombres en español `snake_case`; API de Godot en inglés.
- Comunicación por señales; referencias con `@export`/`@onready`.
- Cero números mágicos de balance: todo en `GameConfig` y en `docs/balance-propuesta.md`.
- Lógica pura separada de nodos.
- Una rama por ticket; commit `TICKET 001.X: ...`; merge a `main` con verificación en verde.
- No se editan a mano `.tscn`, `.tres`, `project.godot` ni `export_presets.cfg`.
- El agente escribe scripts, tests, tools y docs; el editor configura escenas, autoloads, capas y export.

## Assets

- Skins CC0 de Quaternius en `assets/skins/`: `mushnub.glb`, `mushnub_evolved.glb`, `mushroom_king.glb`.
- NPC CC0 en `assets/npcs/`: `amanita.glb` (Kenney), `cubensis.glb` y `melena.glb` (Quaternius).
- Decoración CC0 en `assets/decor/`: `plant.glb`, `bush.glb`, `rocks.glb`, `grass.glb`, `tall_grass.glb`, `flower.glb` (Quaternius); se instancia con `MultiMesh` sin colisión.
- El piso recibe un material procedural de pasto (`FastNoiseLite` + `NoiseTexture2D`) generado por código en el controlador.
- El cielo usa un `ProceduralSkyMaterial` simple de 3 colores, sin texturas grandes.
- Los `.glb` se importan desde el editor y generan `.import`; sin importación hay fallback a primitivas.
- El resto del estilo es low-poly por código: primitivas, emisión y tintes.

## Rendimiento

- Compatibility; medir con el profiler antes de subir NPC o nutrientes.
- Límites: 24 NPC absolutos, 100 nutrientes activos, 1 dorado/escudo/velocidad.
- Cinemática: 2D, 45 partículas; barata frente a un render 3D.
- Evitar asignaciones por frame; las animaciones de skin cachean el `AnimationPlayer` y los nombres de clip.

## Limitaciones

- Sin audio, multijugador ni guardado.
- La cámara de `v0.9.0-beta` tenía saltos; v2 corrigió delta, foco y margen del SpringArm.
- Los valores de balance son provisionales.
