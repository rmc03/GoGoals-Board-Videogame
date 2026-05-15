# 🌍 GoGoals: Sustainable Adventure

![Godot Engine](https://img.shields.io/badge/Godot_Engine-4.6-blue?style=for-the-badge&logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-100%25-green?style=for-the-badge&logo=godotengine)
![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)

**GoGoals** is a dynamic, educational board game built with **Godot Engine 4.6**. Designed to raise awareness about the United Nations Sustainable Development Goals (SDGs), the game challenges up to 4 players to navigate a 63-tile board, overcome obstacles, and answer trivia questions to reach the finish line.

---

## ⚡ Key Features

* **Multiplayer Support:** Local hot-seat multiplayer for 1 to 4 players.
* **Educational Core:** Integrated quiz system featuring questions across all 17 UN Sustainable Development Goals (SDGs).
* **Dynamic Board Mechanics:** Navigate 63 tiles featuring classic chutes-and-ladders mechanics with animated tokens and dynamic bounce resolution at the finish line.
* **High-Performance Architecture:** A decoupled, signal-driven codebase optimized for Godot's Mobile Renderer.
* **Competitive Ranking:** Persistent local leaderboards sorted by turn efficiency and time.
* **Polished UI/UX:** Smooth transitions, responsive menus, floating animations, and dedicated audio management.

---

## 🚀 Quick Start

To run or edit the game locally, ensure you have **Godot Engine 4.6** (or newer) installed.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/go-goals.git
   cd go-goals
   ```
2. **Open the project:**
   Import `project.godot` into the Godot Engine Project Manager.
3. **Play:**
   Press <kbd>F5</kbd> (or the Play button) to launch the main scene.

### Running Tests

The project includes an automated test suite. You can run it directly from the command line in headless mode:

```bash
godot --headless --script tests/run_tests.gd
```

---

## 📚 Documentation

For developers looking to understand the mechanics or extend the codebase, please refer to our comprehensive documentation:

* 📖 **[Game Design Document (GDD)](docs/GAME_DESIGN.md)**: Details on the win conditions, bounce mechanics, quiz system, and scoring criteria.
* 🏗️ **[Architecture Reference](docs/ARCHITECTURE.md)**: In-depth technical breakdown of the Hierarchical Node-Based architecture, signal topology, and state management.

---

## 📁 Repository Structure

The project is structured to separate domain logic, presentation, and global services:

```text
go-goals/
├── autoloads/                     # Global Singleton Services (GameData, AudioManager, RecordsManager)
├── data/                          # JSON data (Question bank)
├── docs/                          # Technical and design documentation
├── scenes/                        # Godot scene files (.tscn)
│   ├── MenuPrincipal.tscn         # Main landing screen
│   ├── pantalla_de_juego.tscn     # Primary gameplay scene
│   └── EndGameMenu.tscn           # Post-match summary and ranking
├── scripts/                       # Core Source Code
│   ├── Core/                      # Constants, GameState, and shared UIHelpers
│   ├── Data/                      # Board configuration and layout rules
│   ├── Entities/                  # Lightweight domain entities (Board, Tile, Player)
│   ├── Managers/                  # Central orchestrator (GameManager)
│   └── UI/                        # UI behavior scripts (HUD, QuizPanel, PauseMenu)
├── tests/                         # Automated unit tests
├── project.godot                  # Godot configuration file
└── export_presets.cfg             # Build pipeline configurations
```

---

## 🛠️ Exporting

This project is optimized for the **Mobile Renderer**, making it suitable for Windows , Linux, Android, iOS, and Web exports. 

1. Go to **Project > Export** in the Godot editor.
2. Select the desired preset (already pre-configured in `export_presets.cfg`).
3. Click **Export Project**.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
