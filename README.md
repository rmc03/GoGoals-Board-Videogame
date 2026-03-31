# GoGoals

Educational board game built with Godot Engine 4.5. Players advance across a 63-tile board by rolling dice and answering questions about the United Nations Sustainable Development Goals (SDGs).

```
Godot 4.5  |  MIT License  |  GDScript  |  Mobile Renderer
```

## Documentation

- [How the Game Works](./docs/HOW_THE_GAME_WORKS.md) — rules, controls, board layout, and game systems
- [Architecture](./docs/ARCHITECTURE.md) — system design, component structure, and communication patterns

## Quick Start

1. Clone the repository.
2. Open `project.godot` in Godot Engine 4.5 or later.
3. Press F5 to run.

To run the test suite from the command line:

```
godot --headless --script tests/run_tests.gd
```

## Project Structure

```
go-goals/
├── Assets/                        # Sprites, fonts, audio files
├── autoloads/                     # Global singleton services
│   ├── GameData.gd                # Question bank loader and accessor
│   ├── AudioManager.gd            # Music and SFX playback
│   └── RecordsManager.gd          # Ranking persistence and sorting
├── data/
│   └── questions.json             # 17 SDG question categories
├── docs/                          # Project documentation
├── scenes/                        # Godot scene files (.tscn)
│   ├── pantalla_de_juego.tscn     # Primary game scene
│   └── FichaJugador.tscn          # Player token scene
├── scripts/
│   ├── Core/
│   │   ├── Constants.gd           # Global constants
│   │   └── GameState.gd           # Session state model
│   ├── Data/
│   │   └── BoardConfig.gd         # Board layout rules
│   ├── Entities/
│   │   ├── Board.gd               # Board entity and path calculation
│   │   ├── Tile.gd                # Tile entity
│   │   └── Player.gd              # Player token entity
│   ├── Managers/
│   │   └── GameManager.gd         # Central game coordinator
│   ├── UI/
│   │   ├── Game/
│   │   │   ├── GameHUD.gd         # Heads-up display
│   │   │   ├── QuizPanel.gd       # Quiz question panel
│   │   │   ├── PauseMenu.gd       # Pause menu
│   │   │   └── BoardTileVisual.gd # Tile visual component
│   │   └── Menu/
│   │       └── OptionsMenu.gd     # Options menu
│   ├── MainBoard.gd               # Composition root for the game scene
│   └── IconoFlotante.gd           # Floating icon animation
├── ui/                            # UI scene files
│   ├── MenuPrincipal.tscn
│   ├── EndGameMenu.tscn
│   └── ComoJugar.tscn
├── tests/
│   └── run_tests.gd               # Unit test runner
├── project.godot
└── export_presets.cfg
```

## Core Components

| Component | File | Role |
|-----------|------|------|
| `GameManager` | `scripts/Managers/GameManager.gd` | Turn orchestration, dice, movement, quiz flow, victory detection |
| `GameState` | `scripts/Core/GameState.gd` | Mutable session state: phase, active player, positions, turn counts |
| `BoardEntity` | `scripts/Entities/Board.gd` | Board structure, tile lookup, path calculation with bounce logic |
| `TileEntity` | `scripts/Entities/Tile.gd` | Tile type classification and metadata |
| `PlayerEntity` | `scripts/Entities/Player.gd` | Token position, offset, and animated movement |
| `BoardConfig` | `scripts/Data/BoardConfig.gd` | Ladders, slides, quiz tile mappings, ODS visual metadata |
| `GameHUD` | `scripts/UI/Game/GameHUD.gd` | Stats panel, dice button, timer, turn indicator |
| `QuizPanelUI` | `scripts/UI/Game/QuizPanel.gd` | Question rendering, option selection, answer feedback |
| `MainBoard` | `scripts/MainBoard.gd` | Composition root: instantiates and wires all game components |

## Board Layout

63 tiles (0–62). Distribution:

| Type | Positions | Effect |
|------|-----------|--------|
| START | 0 | Initial position |
| FINISH | 62 | Victory condition |
| LADDER | 8 → 24, 43 → 49 | Advance to a higher tile |
| SLIDE | 18 → 13, 28 → 1, 40 → 26, 59 → 35 | Retreat to a lower tile |
| QUIZ | 2, 6, 11, 14, 17, 19, 23, 27, 31, 34, 37, 41, 44, 47, 52, 55, 61 | SDG question prompt |
| NORMAL | All others | No effect |

## Data Persistence

| Data | Location | Format |
|------|----------|--------|
| Question bank | `res://data/questions.json` | JSON |
| Ranking records | `user://records.save` | JSON |
| Audio settings | `user://settings.save` | JSON |

## Export

The project targets mobile rendering. To export:

1. Open Project > Export in the Godot editor.
2. Add a preset for the desired platform.
3. Click Export Project.

Export presets are preconfigured in `export_presets.cfg`.

## License

MIT. See the repository root for details.
