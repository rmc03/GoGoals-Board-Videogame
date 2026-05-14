# Game Design Document (GDD)

This document serves as the comprehensive reference for the rules, mechanics, and core gameplay systems of **GoGoals**.

---

## 1. Win Condition

The primary objective is to be the first player to land exactly on the final tile (Tile 62). 

### 1.1 The Bounce Mechanic
If a player's dice roll yields a number that would move their token beyond the final tile, the token will "bounce" backward. 

**Example:**
* A player is currently on **Tile 60**.
* They roll a **4**.
* The movement path will be: `60 → 61 → 62 (Finish) → 61 → 60`.
* The token settles on Tile 60, meaning the player must roll exactly a **2** on their next turn to win.

### 1.2 Leaderboard Scoring
Upon winning, the player's performance is ranked based on two metrics:
1. **Efficiency (Primary):** The lowest number of total turns taken.
2. **Speed (Secondary/Tiebreaker):** The least amount of elapsed time.

---

## 2. The Core Loop

Matches are played in a hot-seat, turn-based format.

### 2.1 Turn Sequence
1. The active player triggers their turn by interacting with the Dice Button.
2. A random integer between 1 and 6 is generated.
3. The player's token automatically animates forward, one tile at a time.
4. Upon reaching the destination tile, the system inspects the tile's properties and applies its specific effect.
5. The turn resolves, either passing control to the next player, or granting the active player a bonus roll.

### 2.2 Turn Continuation (Bonus Rolls)
If a player lands on a **Quiz Tile** and answers the trivia question correctly, they are rewarded with an immediate bonus roll. This is the sole mechanic in the game that permits consecutive turns for a single player.

---

## 3. Board Mechanics

The game board consists of **63 tiles** (indexed 0 through 62). Tile 0 is the universal starting point.

### 3.1 Tile Distribution and Effects

| Type | Positions | Effect |
|------|-----------|----------|
| **START** | `0` | Initial spawn point. No secondary effects. |
| **FINISH** | `62` | Victory condition. Landing here ends the match. |
| **LADDER** | `8 → 24`, `43 → 49` | Token is automatically advanced to the higher target position. |
| **SLIDE** | `18 → 13`, `28 → 1`, `40 → 26`, `59 → 35` | Token is automatically retreated to the lower target position. |
| **QUIZ** | `2, 6, 11, 14, 17, 19, 23, 27, 31, 34, 37, 41, 44, 47, 52, 55, 61` | Pauses movement and triggers a trivia question related to the UN Sustainable Development Goals (SDGs). |
| **NORMAL** | All remaining | Safe zones. The turn ends immediately. |

*Note: Ladders and Slides are evaluated recursively. If a Ladder drops a token onto a Quiz tile, the Quiz will immediately trigger.*

---

## 4. The Quiz System

The educational core of GoGoals relies on a robust trivia system loaded from an external JSON bank (`data/questions.json`).

### 4.1 Question Pooling
1. The question bank is divided into 17 distinct categories, mapping directly to the 17 SDGs.
2. When a player lands on a Quiz Tile, the system identifies the tile's assigned SDG category.
3. The system pulls a random question from that category's available pool.
4. Once a question is asked, it is removed from the active pool to prevent repetition.
5. **Cycle Reset:** If a specific category's pool is entirely depleted during a match, it automatically refills and reshuffles.

### 4.2 Answer Resolution
* **Shuffling:** Every time a question is presented, the 2 to 3 available answers are randomized visually to prevent position-based memorization.
* **Feedback:** Selecting an answer instantly highlights the correct choice in green and incorrect choices in red. A status chip and corresponding audio cue reinforce the outcome.
* **Success:** A correct answer yields a bonus roll.
* **Failure:** An incorrect answer simply ends the turn.

---

## 5. Persistence and Tracking

### 5.1 Match Statistics
The game tracks a rich set of metrics during the match, which are displayed upon victory:
* **Accuracy:** Percentage of quizzes answered correctly.
* **Best Streak:** Maximum consecutive correct answers.
* **Traversal:** Total ladders taken, slides taken, and unique SDG categories encountered.

### 5.2 Local Storage
Data is persisted locally within the Godot `user://` directory:
* **`records.save`**: Stores the Top 10 leaderboard entries in JSON format. Submitting a score under an existing name only overrides the previous record if the new result is superior.
* **`settings.save`**: Stores the player's preferred Music and SFX volume levels.

---

## 6. Audio Architecture

The game utilizes a centralized `AudioManager` for persistent audio and ephemeral SFX spawning:

| Channel | Type | Trigger / Implementation |
|---------|------|-------------|
| **Background Music** | Looping | Persistent stream managed by `AudioManager`. Cross-scene capable. |
| **Dice Roll** | One-shot | Fired upon interacting with the dice button. |
| **Step** | One-shot | Fired rapidly per tile during token movement animations. |
| **Ladder / Slide** | One-shot | Fired when a special traversal tile is activated. |
| **Correct / Wrong** | One-shot | Fired immediately upon resolving a quiz. |
| **Victory** | One-shot | Fired on the end-game screen. |
