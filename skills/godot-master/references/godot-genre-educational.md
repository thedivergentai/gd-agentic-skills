> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Genre: Educational / Gamification**. Accessed via Godot Master.

# Genre: Educational / Gamification

Expert blueprint for building educational games and gamified learning experiences. Focuses on mastery-based progression, adaptive difficulty (Flow State maintenance), and heavy positive reinforcement (Juice).

## Available Scripts

### [adaptive_difficulty_adjuster.gd](../scripts/godot-genre-educational_adaptive_difficulty_adjuster.gd)
A sophisticated logic engine that tracks student performance. It dynamically adjusts question complexity to target a ~70% success rate (the "Flow State") and provides progressive hint disclosure when a student triggers consecutive errors on the same topic.


## NEVER Do

- **NEVER punish failure with a "Game Over"** — Learning requires a safe environment for experimentation. Do not use hard fail states that force a restart. Use **"Try Again"** or provide a **Contextual Hint** to guide the student toward the correct answer.
- **NEVER separate the learning from the gameplay** — Avoid the "Chocolate-covered broccoli" syndrome where the player does a task, then reads a wall of text. The **mechanic MUST be the learning** (e.g., a math game where you must calculate the correct trajectory to clear a gap).
- **NEVER use walls of text for instruction** — Contemporary learners have low patience for reading manuals. **Show, Don't Tell**: Use non-verbal tutorials, interactive diagrams, and 3-second looping GIFs to explain concepts.
- **NEVER skip "Spaced Repetition"** — If a student answers a question correctly once, they haven't mastered it. Successfully answered questions should reappear after increasing intervals to ensure long-term retention.
- **NEVER hide the player's progress** — Mastery is inherently motivating. Always display **Mastery %**, **XP Bars**, and **Skill Trees** prominently to show the student exactly how much they have accomplished and what is next.
- **NEVER use static difficulty** — A student who is crushing every question will get bored, and a student who is failing will get frustrated. Use **Adaptive Difficulty scaling** to keep the challenge commensurate with the current skill level.

---

## The Learning Loop (Gamification)
1. **Instruction**: Brief intro via `RichTextLabel` with BBCode highlights.
2. **Interaction**: Player performs a task (e.g., Drag-and-Drop, Quiz, Simulation).
3. **Reward**: Instant "Juice" (Confetti, high-pitch chime, XP gain).
4. **Correction**: If incorrect, provide a hint that reduces complexity without giving the answer away.

## Student Profiles & Persistence
Store student data in a `Resource` or `JSON` file:
- `topic_mastery`: `Dictionary` (e.g., `{"fractions": 0.85}`)
- `total_xp`: `int`
- `last_seen`: `timestamp` (for calculating spaced repetition intervals)

## Adaptive Hints System
- **Attempt 1 (Fail)**: Generic "Not quite, try again!"
- **Attempt 2 (Fail)**: Visual hint (Highlighting the relevant part of the problem).
- **Attempt 3 (Fail)**: Explicit explanation of the logic required.

## Juice: The "Duolingo" Effect
To keep students engaged, use Godot's `Tween` system to make the UI feel alive:
- **Progress Bars**: Tween the `value` property smoothly rather than snapping.
- **Milestones**: When a topic is mastered, trigger a full-screen particle celebration.
- **Streaks**: Track consecutive days played to encourage habit formation.

## Interactive Quizzes (Drag & Drop)
Godot's `Control` nodes have built-in `_get_drag_data` and `_can_drop_data`. Use these for:
- Matching terms to definitions.
- Sorting elements in chronological order.
- Dragging components to assemble a machine.

## Reference
- [Godot Docs: Localization and Translation](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html)
- [GDC: The Psychology of Learning in Games](https://www.youtube.com/watch?v=kYv9lS9eU0U)
