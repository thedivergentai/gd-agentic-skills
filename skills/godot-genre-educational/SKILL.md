---
name: godot-genre-educational
description: "Expert blueprint for educational games including gamification loops (learn/apply/feedback/adapt), progress tracking (student profiles, mastery %), adaptive difficulty (target 70% success rate), spaced repetition, curriculum trees (prerequisite system), and visual feedback (confetti, XP bars). Use for learning apps, training simulations, or edutainment. Trigger keywords: educational_game, gamification, adaptive_difficulty, spaced_repetition, student_profile, curriculum_tree, mastery_tracking."
---

# Genre: Educational / Gamification

Expert blueprint for educational games that make learning engaging through game mechanics.

## NEVER Do

- **NEVER punish failure with "Game Over"** — Learning requires safe experimentation. Use "Try Again" or "Here's a Hint" instead of fail states.
- **NEVER separate learning from gameplay** — "Chocolate-covered broccoli" feels like homework. Make mechanics BE the learning (e.g., Typing of the Dead).
- **NEVER use walls of text** — Players skip tutorials. Show, don't tell. Interaction first, then brief explanations.
- **NEVER skip spaced repetition** — Questions answered incorrectly should reappear later. One-time questions don't build mastery.
- **NEVER hide progress from learners** — Visible XP bars, mastery %, and skill trees motivate continued learning. Opaque systems frustrate.
---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [adaptive_difficulty_adjuster.gd](scripts/adaptive_difficulty_adjuster.gd)
Success-ratio tracking with branching hints. Adjusts difficulty up/down based on sliding window, provides progressive hint disclosure on consecutive fails.

---

## Core Loop
1.  **Learn**: Player receives new information (text, diagram, video).
2.  **Apply**: Player solves a problem or completes a task using that info.
3.  **Feedback**: Game provides immediate correction or reward.
4.  **Adapt**: System adjusts future questions based on performance.
5.  **Master**: Player unlocks new topics or cosmetic rewards.

## Skill Chain

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. UI | `godot-ui-rich-text`, `godot-ui-theming` | Readable text, drag-and-drop answers |
| 2. Data | `godot-save-load-systems`, `json-serialization` | Student profiles, progress tracking |
| 3. Logic | `state-machine` | Quiz flow (Question -> Answer -> Result) |
| 4. Juice | `godot-particles`, `godot-tweening` | Making learning feel rewarding |
| 5. Meta | `godot-scene-management` | Navigating between lessons and map |

## Architecture Overview

### 1. The Curtain (Question Manager)
Manages the flow of a single "Lesson" or "Quiz".

```gdscript
# quiz_manager.gd
extends Node

var current_question: QuestionData
var correct_streak: int = 0

func submit_answer(answer_index: int) -> void:
    if current_question.is_correct(answer_index):
        handle_success()
    else:
        handle_failure()

func handle_success() -> void:
    correct_streak += 1
    EffectManager.play_confetti()
    StudentProfile.add_xp(current_question.topic, 10)
    load_next_question()

func handle_failure() -> void:
    correct_streak = 0
    # Spaced Repetition: Add this question back to the queue
    question_queue.push_back(current_question)
    show_explanation()
```

### 2. The Student Profile
Persistent data tracking mastery.

```gdscript
# student_profile.gd
class_name StudentProfile extends Resource

@export var topic_mastery: Dictionary = {} # "math_add": 0.5 (50%)
@export var total_xp: int = 0
@export var badges: Array[String] = []

func get_mastery(topic: String) -> float:
    return topic_mastery.get(topic, 0.0)
```

### 3. Curriculum Tree
Defining the dependency graph of knowledge.

```gdscript
# curriculum_node.gd
extends Resource
@export var id: String
@export var title: String
@export var required_topics: Array[String] # Prereqs
```

## Key Mechanics Implementation

### Adaptive Difficulty algorithm
If player is crushing it, give harder questions. If struggling, ease up.

```gdscript
func get_next_question() -> QuestionData:
    var player_rating = StudentProfile.get_rating(current_topic)
    # Target a 70% success rate for "Flow State"
    var target_difficulty = player_rating + 0.1 
    return QuestionBank.find_question(target_difficulty)
```

### Juice (The "Duolingo Effect")
Learning is hard. The game must heavily reward effort visually.
*   **Sound**: Satisfying "Ding!" on correct.
*   **Visuals**: Screen shake, godot-particles, multiplier popup.
*   **UI**: Progress bars filling up smoothly (Tweening).

## Godot-Specific Tips

*   **RichTextLabel**: Essential for mathematical formulas or coloring keywords (BBCode).
*   **Drag and Drop**: Godot's Control nodes have built-in `_get_drag_data` and `_drop_data` methods. Perfect for "Match the items" puzzles.
*   **Localization**: Educational games often need to support multiple languages. Use Godot's `TranslationServer` from day one.

## Common Pitfalls

1.  **Chocolate-Covered Broccoli**: Game loop and Learning loop are separate. **Fix**: Make the mechanic *be* the learning (e.g., Typing of the Dead).
2.  **Punishing Failure**: Player gets "Game Over" for being wrong. **Fix**: Never fail state. Just "Try Again" or "Here's a hint".
3.  **Wall of Text**: Too much reading. **Fix**: Interaction first. Show, don't tell.


## Reference
- Master Skill: [godot-master](../godot-master/SKILL.md)
