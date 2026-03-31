# GoGoals - Board Videogame

A fun educational board game about Sustainable Development Goals (SDGs) built with Godot Engine 4.

![Godot Version](https://img.shields.io/badge/Godot-4.5-blue)
![License](https://img.shields.io/badge/License-MIT-green)

**Documentation:**
- [How the Game Works](./docs/HOW_THE_GAME_WORKS.md)
- [Architecture](./docs/ARCHITECTURE.md)

## Overview

GoGoals is a board game where players race to reach the final tile by answering questions about the UN Sustainable Development Goals (SDGs). Players answer questions correctly to gain advantages and climb the ranking.

## Objective

- Reach the final tile before other players
- Answer SDG questions correctly to gain advantages
- Achieve the best score in the ranking (fewest turns and shortest time)

## How to Play

### Game Flow
1. **Main Menu**: Select the number of players (1-4)
2. **Roll Dice**: Each turn, roll the dice to move your token
3. **Tile Effects**: Land on special tiles for different events:
   - **SDG Tile**: Answer a question — correct answers let you roll again
   - **Ladder**: Move forward to a higher tile
   - **Slide**: Move backward to a lower tile
4. **Victory**: First player to reach the final tile wins!

### Controls
- **Roll Dice**: Click/tap the dice button to roll
- **Pause**: Press ESC or click the pause button to open the pause menu
- **Quiz**: Select an answer option to respond

## Architecture

This project uses a **Hierarchical Node-Based Architecture**, supported by global services and centrally coordinated. The design follows four fundamental pillars:

### 1. Scene-Driven Architecture

Navigation and UI boundaries rely on Godot's native scene system. The main menu, the interactive game screen, and the end-game menu act as natural presentation boundaries. Within the game, the main level acts as a local composition root, assembling dependencies and connecting the UI with logic without directly mixing their responsibilities.

### 2. Global Services via Autoloads

Godot facilitates the Singleton pattern through globally registered nodes, allowing cross-cutting concerns to be accessed from any scene. The project uses:
- **`GameData`** — maintains game configuration and loads the question bank
- **`AudioManager`** — centralizes music and sound effect playback
- **`RecordsManager`** — manages local score persistence in a structured and independent manner

### 3. Central Coordination and Event-Driven Communication

Instead of a strict Model-View-Controller pattern, the game flow is orchestrated by a central application coordinator (`GameManager`). This component concentrates the main use cases: turn control, movement, questions, and victory. To achieve low coupling, communication to the UI is governed by signals (Event Bus). Interfaces like the quiz panel react independently to events without depending on the coordinator's internal code.

### 4. Separated State Model and Lightweight Entities

The mutable game state (game phase, current turn, roll count) is isolated in an explicit state model (`GameState`), which facilitates managing pauses or game overs. Additionally, the domain is represented through lightweight interactive entities (board logic, tiles, and tokens) that encapsulate their own behavior but delegate global flow control to the game coordinator.

## Project Structure

```
go-goals/
├── Assets/                    # Sprites, fonts, audio
├── autoloads/                 # Global singleton services
│   ├── GameData.gd            # Question bank access
│   ├── AudioManager.gd        # Audio control
│   └── RecordsManager.gd      # Ranking persistence
├── data/                      # JSON data files
│   └── questions.json         # SDG question bank
├── docs/                      # Documentation
├── scenes/                    # Godot scenes (.tscn)
│   ├── pantalla_de_juego.tscn # Main game scene
│   └── FichaJugador.tscn      # Player token scene
├── scripts/                   # GDScript source code
│   ├── Core/
│   │   ├── Constants.gd       # Game constants
│   │   └── GameState.gd       # Session state model
│   ├── Data/
│   │   └── BoardConfig.gd     # Board configuration data
│   ├── Entities/
│   │   ├── Board.gd           # Board entity
│   │   ├── Tile.gd            # Tile entity
│   │   └── Player.gd          # Player entity
│   ├── Managers/
│   │   └── GameManager.gd     # Central game coordinator
│   ├── UI/
│   │   ├── Game/
│   │   │   ├── GameHUD.gd     # Heads-up display
│   │   │   ├── QuizPanel.gd   # Quiz interface
│   │   │   ├── PauseMenu.gd   # Pause menu
│   │   │   └── BoardTileVisual.gd # Tile visual component
│   │   └── Menu/
│   │       └── OptionsMenu.gd # Options menu
│   ├── MainBoard.gd           # Composition root for game scene
│   └── IconoFlotante.gd       # Floating icon animation
├── ui/                        # UI scenes
│   ├── MenuPrincipal.tscn     # Main menu scene
│   ├── EndGameMenu.tscn       # End game scene
│   └── ComoJugar.tscn         # How to play scene
├── tests/                     # Unit tests
│   └── run_tests.gd           # Test runner
├── project.godot              # Godot project file
└── export_presets.cfg         # Export configuration
```

### Key Components

| Component | Responsibility |
|-----------|----------------|
| `GameManager` | Central coordinator — handles turns, dice, movement, quiz, victory |
| `GameState` | Mutable session state — time, active player, positions, turn count |
| `BoardEntity` | Board structure representation |
| `TileEntity` | Individual tile type and metadata |
| `PlayerEntity` | Player token and position |
| `GameHUD` | Displays stats, dice, and game info |
| `QuizPanelUI` | Renders and processes SDG questions |
| `MainBoard` | Composition root — assembles and wires all components |
| `BoardConfig` | Board rules: ladders, slides, quiz tiles, ODS visuals |

### Data-Driven Elements
- **Questions**: Loaded from `data/questions.json`
- **Ranking**: Saved to `user://records.save`
- **Settings**: Audio volumes saved to `user://settings.save`
- **Board Config**: Defined in `scripts/Data/BoardConfig.gd`

## Board Layout

The board has **63 tiles** (0–62) with the following distribution:

| Type | Tiles | Effect |
|------|-------|--------|
| START | 0 | Starting position |
| FINISH | 62 | Goal (victory) |
| LADDER | 8→24, 43→49 | Advances to a higher tile |
| SLIDE | 18→13, 28→1, 40→26, 59→35 | Moves back to a lower tile |
| QUIZ | 17 tiles (2, 6, 11, 14, 17, 19, 23, 27, 31, 34, 37, 41, 44, 47, 52, 55, 61) | SDG question |
| NORMAL | Remaining | No effect |

## Technical Features

- **Signal-based Communication**: Components communicate via Godot signals (Observer pattern)
- **Persistent Ranking**: Local storage saves top 10 scores
- **Question Bank**: 17 SDG categories loaded from JSON with cycle-without-repeats logic
- **Audio System**: Background music and SFX management with volume persistence
- **Responsive UI**: Adaptive game interface with programmatic layout
- **Bounce Mechanics**: Players bounce back from the finish tile if they overshoot
- **Quiz Randomization**: Answer options are shuffled on every question
- **Match Statistics**: Tracks accuracy, streaks, unique ODS visited, ladders/slides taken

## Getting Started

### Requirements
- Godot Engine 4.5+
- Git (for version control)

### Running the Game
1. Clone the repository
2. Open `project.godot` in Godot 4
3. Press F5 or click Play

### Running Tests
```bash
godot --headless --script tests/run_tests.gd
```

### Exporting
1. Go to Project > Export
2. Select your target platform (Windows, Web, etc.)
3. Click Export Project

## Credits

- Audio: Legend of Dragoon OST (Royal Castle Extended)
- Fonts: Adventure ReQuest, Gameshow, Ticketing, Lilita One

## License

MIT License — Feel free to use and modify this project!
