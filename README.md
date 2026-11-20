# ESPORA.io

Juego 3D .io de un solo jugador: controlás una espora que crece absorbiendo nutrientes y compite por el claro contra hongos NPC.

Los humanos se extinguieron. Bajo la tierra, la red de micelio despertó y ahora los hongos se disputan el mundo. Esa es la historia de v2: [docs/historia.md](docs/historia.md).

## Estado

- Rama `main` con la v2 en curso.
- Beta anterior: `v0.9.0-beta` (tag `v0.9.0-beta`, commit `fcc43d8`), con artefactos en `builds/`.
- La release v2 (tag, build y changelog) se hace al cerrar el TICKET 001.

## Requisitos

- Windows 10/11 x64 para jugar el `.exe`.
- Godot **4.7.2-stable** para editar o ejecutar desde el proyecto.
- Renderer **Compatibility** (sin GPU dedicada).
- `GODOT_BIN` apuntando al ejecutable de Godot para `tools/verify.ps1`.

## Jugar

- Beta v0.9.0: `builds/espora.exe` (o el ZIP de la release).
- v2: abrir el proyecto en Godot 4.7.2 y presionar **F5**; la build v2 se genera al cerrar el TICKET 001.
- Si Windows SmartScreen bloquea el `.exe`: **Más información** → **Ejecutar de todas formas**. El binario no está firmado.

## Controles

| Acción | Entrada |
|---|---|
| Mover | `WASD` |
| Cámara | mouse |
| Disparar espora | clic izquierdo |
| Pausa / saltar cinemática | `Esc` |
| Debug: simular impacto | `F1` (solo build de depuración) |
| Debug: saltar horda | `F2` (solo build de depuración) |

## Tests

La suite usa gdUnit4 y cubre lógica pura (155 tests, 22 suites):

```powershell
$env:GODOT_BIN = "C:\ruta\a\Godot_v4.7.2-stable_win64.exe"
.\tools\verify.ps1
```

El script importa recursos, valida sintaxis, carga la escena principal y corre los tests. Para correr solo gdUnit4:

```powershell
& $env:GODOT_BIN --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests
```

## Exportar

El preset **Windows Desktop** vive en `export_presets.cfg` y exporta a `builds/espora.exe` (PCK embebido, x86_64).

1. Abrir el proyecto en Godot 4.7.2.
2. `Proyecto` → `Exportar` → `Windows Desktop` → `Exportar proyecto`.
3. Verificar que el `.exe` actualizado quede en `builds/`.

La exportación es un paso manual del editor; no se edita `export_presets.cfg` a mano.

## Estructura

```text
core/       GameManager, GameConfig y lógica pura (biomas, hordas, puntaje, tamaño)
entities/   jugador, NPC, espora, nutriente y pickups
world/      arena, controlador de partida, spawners y tinte de biomas
ui/         menú, skins, pausa, carga, cinemática, HUD y resultado
tests/      suite gdUnit4
tools/      verify.ps1
docs/       manual, arquitectura, historia, balance y releases
assets/     modelos CC0 de skins
builds/     artefactos de exportación
addons/     gdUnit4 y Godot Editor MCP
```

## Documentación

- [Manual del jugador](docs/manual-jugador.md)
- [Arquitectura](docs/arquitectura.md)
- [Historia](docs/historia.md)
- [Balance propuesto](docs/balance-propuesta.md)
- [Investigación de desarrollo](docs/investigacion-desarrollo.md)
- [Release v0.9.0-beta](docs/releases/v0.9.0-beta.md)
- [Reglas del proyecto](AGENTS.md)

## Capturas

Las capturas reales van en `docs/capturas/`: ver [instrucciones](docs/capturas/README.md). Agregar 2–3 imágenes del menú, la partida y el resultado.

## Créditos

- Modelos de skins: **Quaternius** (Mushnub, Mushnub Evolved, Mushroom King), CC0, vía [poly.pizza](https://poly.pizza).
- Motor: [Godot Engine](https://godotengine.org) 4.7.2.
- Tests: [gdUnit4](https://github.com/MikeSchulze/gdUnit4).
- Resto de assets y código: proyecto ESPORA.io.

## Problemas conocidos

- El `.exe` no está firmado: SmartScreen puede advertir.
- Sin audio, sin multijugador y sin persistencia de skins entre sesiones.
- La cámara de la beta `v0.9.0-beta` tenía saltos; en v2 se corrigió el delta del mouse, el foco y el margen del SpringArm.
- Renderer Compatibility en hardware modesto; medir antes de subir NPC o nutrientes.

## Notion

- [TICKET 000 — ESPORA.io (beta)](https://app.notion.com/p/TICKET-000-ESPORA-io-400fd5d7f03f80fba1e5eeca7d4f1f40)
- [TICKET 001 — ESPORA v2](https://app.notion.com/p/40cfd5d7f03f818e989cf11b9d4cdece)
