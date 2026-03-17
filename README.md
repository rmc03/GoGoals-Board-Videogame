# GoGoals - Board Videogame

A fun educational board game about Sustainable Development Goals (SDGs) built with Godot Engine 4.

![Godot Version](https://img.shields.io/badge/Godot-4.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 Overview

GoGoals is a board game where players race to reach the final tile by answering questions about the UN Sustainable Development Goals (SDGs). Players answer questions correctly to gain advantages and climb the ranking.

## 🎯 Objective

- Reach the final tile before other players
- Answer ODS (SDG) questions correctly to gain advantages
- Achieve the best score in the ranking (fewest turns and shortest time)

## 🕹️ How to Play

### Game Flow
1. **Main Menu**: Select the number of players (2-4)
2. **Roll Dice**: Each turn, roll the dice to move your token
3. **Tile Effects**: Land on special tiles for different events:
   - **ODS Tile**: Answer a question - correct answers let you continue or gain advantages
   - **Ladder**: Move forward to a higher tile
   - **Slide**: Move backward to a lower tile
4. **Victory**: First player to reach the final tile wins!

### Controls
- **Roll Dice**: Click/tap the dice button to roll
- **Pause**: Press ESC or click pause to open the pause menu
- **Quiz**: Select an answer option to respond

## 🏗️ Architecture

This project uses a **scene-driven modular architecture** with autoload services and central coordination via signals.

```
scenes/
├── pantalla_de_juego.tscn     # Main game scene
├── FichaJugador.tscn         # Player token
└── ui/                        # UI components

scripts/
├── Core/
│   ├── Constants.gd          # Game constants
│   └── GameState.gd          # Session state
├── Entities/
│   ├── Board.gd              # Board entity
│   ├── Tile.gd               # Tile entity
│   └── Player.gd             # Player entity
├── Managers/
│   └── GameManager.gd        # Core game logic
├── UI/
│   ├── Game/
│   │   ├── GameHUD.gd        # Heads-up display
│   │   ├── QuizPanel.gd      # Quiz interface
│   │   └── PauseMenu.gd      # Pause menu
│   └── Menu/
│       └── OptionsMenu.gd    # Options menu

autoloads/
├── GameData.gd               # Question bank access
├── RecordsManager.gd         # Ranking persistence
└── AudioManager.gd          # Audio control
```

### Key Components

| Component | Responsibility |
|-----------|----------------|
| `GameManager` | Central coordinator - handles turns, dice, movement, quiz, victory |
| `GameState` | Mutable session state - time, active player, positions, turn count |
| `BoardEntity` | Board structure representation |
| `TileEntity` | Individual tile type and metadata |
| `PlayerEntity` | Player token and position |
| `GameHUD` | Displays stats, dice, and game info |
| `QuizPanel` | Renders and processes ODS questions |

### Data-Driven Elements
- **Questions**: Loaded from `data/questions.json`
- **Ranking**: Saved to `user://records.save`
- **Board Config**: Defined in `scripts/Data/BoardConfig.gd`

## 📂 Project Structure

```
go-goals/
├── Assets/                   # Sprites, fonts, audio
├── autoloads/               # Global singleton services
├── data/                    # JSON data files
├── docs/                    # Documentation
├── scenes/                  # Godot scenes (.tscn)
├── scripts/                 # GDScript source code
├── ui/                      # UI resources
├── project.godot            # Godot project file
└── export_presets.cfg       # Export configuration
```

## 🧩 Technical Features

- **Signal-based Communication**: Components communicate via Godot signals (Observer pattern)
- **Persistent Ranking**: Local storage saves top scores
- **Question Bank**: ODS questions loaded from JSON
- **Audio System**: Background music and SFX management
- **Responsive UI**: Adaptive game interface

## 🚀 Getting Started

### Requirements
- Godot Engine 4.x
- Git (for version control)

### Running the Game
1. Clone the repository
2. Open `project.godot` in Godot 4
3. Press F5 or click Play

### Exporting
1. Go to Project > Export
2. Select your target platform (Windows, Web, etc.)
3. Click Export Project

## 📝 Documentation

- [How the Game Works](./docs/COMO_FUNCIONA_JUEGO.md) (Spanish)
- [Architecture Documentation](./docs/ARQUITECTURA_JUEGO.md) (Spanish)

## 🎵 Credits

- Audio: Legend of Dragoon OST (Royal Castle Extended)
- Fonts: Adventure ReQuest, Gameshow, Ticketing

## 📄 License

MIT License - Feel free to use and modify this project!
