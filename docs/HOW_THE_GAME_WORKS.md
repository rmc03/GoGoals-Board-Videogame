# How the Game Works

Rules, systems, and mechanics reference for GoGoals.

---

## Win Condition

The first player to land exactly on tile 62 (the finish tile) wins the match. If a dice roll would carry a player past the finish, the token bounces backward (see [Bounce Mechanics](#bounce-mechanics)).

The ranking score is determined by two factors, in order of priority:

1. Fewer total turns.
2. Less elapsed time (tiebreaker).

---

## Turn Sequence

Each turn follows this sequence:

1. The active player presses the dice button.
2. A value between 1 and 6 is generated at random.
3. The player's token animates forward one tile at a time.
4. The destination tile is inspected and its effect is resolved.
5. Depending on the result, the turn either continues (quiz success), passes to the next player, or ends the game.

### Turn Continuation

If a player lands on a quiz tile and answers correctly, they roll again immediately. This is the only mechanic that allows consecutive turns for the same player.

---

## Controls

| Input | Action |
|-------|--------|
| Dice button (click/tap) | Roll the dice for the current player |
| ESC key or Pause button | Toggle the pause menu |
| Quiz option buttons | Submit an answer during a quiz |

---

## Board

The board consists of **63 tiles**, indexed 0 through 62. Tile 0 is the starting position. Tile 62 is the finish.

### Tile Types

| Type | Positions | Behavior |
|------|-----------|----------|
| START | 0 | Initial position. No effect when landed on. |
| FINISH | 62 | Victory. Game ends immediately. |
| LADDER | 8 → 24, 43 → 49 | Token is moved to the target position. Destination is then re-evaluated. |
| SLIDE | 18 → 13, 28 → 1, 40 → 26, 59 → 35 | Token is moved to the target position. Destination is then re-evaluated. |
| QUIZ | 2, 6, 11, 14, 17, 19, 23, 27, 31, 34, 37, 41, 44, 47, 52, 55, 61 | Triggers an SDG question for the category assigned to that tile. |
| NORMAL | All remaining positions | No effect. Turn ends. |

Ladders and slides are recursive. If a ladder leads to another special tile, the effect of that tile is also applied.

---

## Bounce Mechanics

When a dice roll would move the token past tile 62, the path reverses direction at the finish tile. The token does not stop at 62 unless it lands on it exactly.

Example: a player on tile 60 rolls a 4.

```
60 → 61 → 62 → 61 → 60
```

The final position is 60. The player must roll a 2 to win.

---

## Quiz System

### Question Selection

Questions are loaded from `data/questions.json` at startup. Each of the 17 SDG categories has its own question pool.

When a quiz tile is triggered:

1. The system identifies the SDG category assigned to that tile.
2. It filters out questions already used in the current match.
3. A random question is selected from the remaining pool.
4. If all questions for a category have been used, the pool resets and cycles again.

### Answer Presentation

Each question has 2 or 3 answer options. Options are **shuffled randomly** every time the question appears, so the correct answer is not always in the same position.

### Feedback

After the player selects an option:

- The correct option is highlighted in green.
- Incorrect options are highlighted in red.
- A status chip indicates whether the answer was correct or incorrect.
- If an explanation is defined in the data, it is displayed alongside the correct answer text.
- Feedback is visible for 1.8 seconds before the panel closes.

### Resolution

| Outcome | Effect |
|---------|--------|
| Correct | Player rolls again. Turn does not end. |
| Incorrect | Turn passes to the next player. |

---

## Pause Menu

The pause menu provides:

- **Music volume slider** (0–100%, persisted to `user://settings.save`).
- **SFX volume slider** (0–100%, persisted to `user://settings.save`).
- **Display mode selector**: fullscreen, windowed, or borderless window.
- **Resume button**: returns to the game.
- **Restart button**: reloads the current scene.
- **Main Menu button**: returns to the main menu.

The game timer is paused while the pause menu is open. Time spent paused does not count toward the ranking score.

---

## Match Statistics

The following statistics are tracked during a match and displayed on the end-game screen:

| Metric | Description |
|--------|-------------|
| Correct answers | Number of questions answered correctly |
| Incorrect answers | Number of questions answered incorrectly |
| Quizzes answered | Total quiz encounters |
| Best streak | Highest number of consecutive correct answers |
| Special tiles triggered | Combined count of ladders and slides activated |
| Ladders taken | Number of ladder tiles landed on |
| Slides taken | Number of slide tiles landed on |
| Unique ODS | Number of distinct SDG categories encountered during the match |
| Pause count | Number of times the pause menu was opened |
| Player turns | Turn count for each player |

---

## Ranking

Records are stored in `user://records.save` as a JSON array. The system maintains up to 10 entries.

Sorting: fewer turns first, then less time. If a player submits a score under a name that already exists, the old record is only replaced if the new one is better.

---

## Audio

The game uses 8 audio channels:

| Channel | Type | Description |
|---------|------|-------------|
| Background music | Looping stream | Plays during the match |
| Dice roll | One-shot SFX | Triggered on roll |
| Step | One-shot SFX | Triggered per tile during movement |
| Ladder | One-shot SFX | Triggered on ladder activation |
| Slide | One-shot SFX | Triggered on slide activation |
| Correct | One-shot SFX | Triggered on correct quiz answer |
| Wrong | One-shot SFX | Triggered on incorrect quiz answer |
| Victory | One-shot SFX | Triggered on game end |

SFX players are created dynamically and auto-removed after playback. Music uses a single persistent player.

---

## Source Reference

| System | File |
|--------|------|
| Turn orchestration, dice, movement, quiz, victory | `scripts/Managers/GameManager.gd` |
| Session state: phase, player index, positions, time | `scripts/Core/GameState.gd` |
| Constants: dice range, volumes, scene paths, tween durations | `scripts/Core/Constants.gd` |
| Board structure and path calculation | `scripts/Entities/Board.gd` |
| Tile type classification and metadata | `scripts/Entities/Tile.gd` |
| Player token, position offset, animated movement | `scripts/Entities/Player.gd` |
| Board rules: ladders, slides, quiz mappings, ODS visuals | `scripts/Data/BoardConfig.gd` |
| In-game HUD: stats panel, dice button, timer | `scripts/UI/Game/GameHUD.gd` |
| Quiz question rendering and answer feedback | `scripts/UI/Game/QuizPanel.gd` |
| Pause menu with audio sliders and display mode | `scripts/UI/Game/PauseMenu.gd` |
| Composition root for the game scene | `scripts/MainBoard.gd` |
| Question bank loading and randomized access | `autoloads/GameData.gd` |
| Music and SFX playback, volume persistence | `autoloads/AudioManager.gd` |
| Ranking storage, sorting, and business rules | `autoloads/RecordsManager.gd` |
| SDG question bank (17 categories) | `data/questions.json` |
