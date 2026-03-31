# How the Game Works

This document summarizes the rules, flow, and main systems of GoGoals.

## Objective

- Reach the final tile before the other players.
- Answer SDG questions correctly to gain advantages and improve your ranking score.

## Game Flow

1. From the main menu, select the number of players (1–4).
2. Each turn, the active player rolls the dice and their token advances the indicated number of tiles.
3. Landing on special tiles triggers events:
   - **SDG Tile**: A question opens. If you answer correctly, you roll again.
   - **Ladder**: You advance to a higher tile.
   - **Slide**: You move back to a lower tile.
4. The game ends when a player reaches the finish tile.

## Controls

- **Roll Dice**: Rolls the dice for the current player.
- **Pause** or **ESC**: Opens the pause menu.
- During a quiz, click an option to submit your answer.

## Board Layout

The board has **63 tiles** (index 0–62):

| Type | Tiles | Effect |
|------|-------|--------|
| START | 0 | Starting position |
| FINISH | 62 | Goal (victory) |
| LADDER | 8→24, 43→49 | Advances to a higher tile |
| SLIDE | 18→13, 28→1, 40→26, 59→35 | Moves back to a lower tile |
| QUIZ | 2, 6, 11, 14, 17, 19, 23, 27, 31, 34, 37, 41, 44, 47, 52, 55, 61 | SDG question |
| NORMAL | Remaining tiles | No effect |

## Bounce Mechanics

If a player's dice roll would take them past the finish tile, the token bounces backward. For example, being on tile 60 and rolling a 4 results in the path: 61 → 62 → 61 → 60. You must land exactly on the finish tile to win.

## Quiz System (SDG)

- Questions are loaded from `data/questions.json`.
- Each SDG (1–17) has its own set of questions.
- Each question has multiple options (2–3) and one correct answer.
- Answer options are **shuffled randomly** each time a question appears.
- Questions cycle without repeats until the bank is exhausted, then recycle.
- After answering, the panel shows:
  - The correct option highlighted in green.
  - Incorrect options highlighted in red.
  - An explanation (if available) and the correct answer text.
- **Correct answer**: The same player rolls again.
- **Incorrect answer**: The turn passes to the next player.

## Pause Menu

- **Audio sliders**: Adjust music and SFX volume (0–100%).
- **Display mode**: Fullscreen, windowed, or borderless window.
- **Buttons**: Resume, Restart, Main Menu.
- Audio settings persist across sessions via `user://settings.save`.

## Ranking

- The top 10 results are saved in `user://records.save`.
- Ranking is sorted by:
  1. Fewer turns (better).
  2. Less total time (tiebreaker).
- Players can register their name after a match to save their record.

## Match Statistics

The game tracks the following statistics per match:

| Statistic | Description |
|-----------|-------------|
| Correct answers | Number of quiz questions answered correctly |
| Incorrect answers | Number of quiz questions answered incorrectly |
| Quizzes answered | Total number of quizzes encountered |
| Best streak | Longest consecutive correct answers |
| Special tiles triggered | Total ladders + slides activated |
| Ladders taken | Number of ladder tiles landed on |
| Slides taken | Number of slide tiles landed on |
| Unique ODS | Number of distinct SDG categories encountered |
| Pause count | Number of times the pause menu was opened |
| Player turns | Turn count per player |

## Technical Summary

| File | Role |
|------|------|
| `scripts/Managers/GameManager.gd` | Central coordinator: turns, dice, movement, quiz, victory |
| `scripts/Core/GameState.gd` | Mutable session state model |
| `scripts/Core/Constants.gd` | Game constants (dice range, volumes, scene paths) |
| `scripts/Entities/Board.gd` | Board structure and path calculation |
| `scripts/Entities/Tile.gd` | Tile type and metadata |
| `scripts/Entities/Player.gd` | Player token and position |
| `scripts/Data/BoardConfig.gd` | Board rules: ladders, slides, quiz tiles, ODS visuals |
| `scripts/UI/Game/GameHUD.gd` | In-game HUD (stats, dice, timer) |
| `scripts/UI/Game/QuizPanel.gd` | Quiz question panel |
| `scripts/UI/Game/PauseMenu.gd` | Pause menu with audio and display settings |
| `scripts/MainBoard.gd` | Composition root for the game scene |
| `autoloads/GameData.gd` | Question bank loading and access |
| `autoloads/AudioManager.gd` | Music and SFX playback management |
| `autoloads/RecordsManager.gd` | Ranking persistence and business rules |
| `data/questions.json` | SDG question bank (17 categories) |

## UI Notes

- The HUD is split into a stats panel (top-right) and a dice button area.
- The ranking panel uses custom row layouts with scroll support.
- The quiz panel animates in/out with scale and fade transitions.
- Player tokens use color coding: purple (J1), red (J2), green (J3), blue (J4).
- The dice button shows an animated sequence of random faces before the final result.
