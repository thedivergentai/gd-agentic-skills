---
name: godot-genre-romance
description: "Expert blueprint for romance games and dating sims (Tokimeki Memorial, Monster Prom, Persona social links) focusing on affection systems, multi-stat relationships, dated events, and route branching. Use when building relationship-centric games, social simulations, or otome games. Keywords romance, dating sim, affection system, relationship stats, date events, character routes, love interest."
---

# Genre: Romance & Dating Sim

Romance games are built on the "Affection Economy"—the management of player time and resources to influence NPC attraction, trust, and intimacy.

## Core Loop
1.  **Meet**: Encounter potential love interests and establish baseline rapport.
2.  **Date**: Engage in structured events to learn preferences and test compatibility.
3.  **Deepen**: Invest resources (time, gifts, choices) to increase affection/stats.
4.  **Branch**: Story diverges into character-specific "Routes" based on major milestones.
5.  **Resolve**: Reach a specialized ending (Good/Normal/Bad) based on relationship quality.

## NEVER Do (Expert Anti-Patterns)

### Romance & NPC Logic
- NEVER create "Vending Machine" romance; strictly incorporate variables like **NPC Mood**, **Timing**, and **Multi-Stat Thresholds** to ensure characters feel autonomous.
- NEVER use binary Affection (Love/Hate); strictly use a **Multi-Axial Model** (Attraction, Trust, Comfort) for believable psychological depth.
- NEVER focus on 100% opaque stats; strictly provide **Visible Indicators** (heart UI, blushing text, pulsing hearts) to help players make informed choices.
- NEVER use the "Same Date Order" trap; strictly implement a **Repetition Penalty** (~30%) for visiting the same location twice in a row.
- NEVER forget "Missable" Milestones; strictly ensure meaningful consequences (e.g., missing events due to poor scheduling) to add weight to the experience.
- NEVER ignore NPC Autonomy; strictly allow NPCs to have their own **Schedules** and the ability to **Reject** the player based on low trust or conflicting events.

### Technical & UI
- NEVER use `_process` for typewriter text; strictly use **Tweens on `visible_ratio`** for frame-independent, smooth reveals.
- NEVER parse massive narrative files on the main thread; strictly use **`ResourceLoader.load_threaded_request()`** to prevent transition stutters.
- NEVER use exact float math for affection checks; strictly use **`is_equal_approx()`** to avoid jitter-based logic failures.
- NEVER structure complex dialogue purely in code; strictly design dialogue trees as **Custom `Resource` classes** to decouple narrative data from logic.
- NEVER rely on the global OS clock for timed choices; strictly use **`SceneTreeTimer`** which respects `Engine.time_scale` and pause states.
- NEVER leave invisible controls with `MOUSE_FILTER_STOP`; strictly set to `IGNORE` or `PASS` on non-opaque layers to avoid blocking dialogue progression.
- NEVER hardcode dialogue strings; strictly map text to **Localization Keys** and retrieve via `tr()` for internationalization.
- NEVER use absolute pixel positioning for interfaces; strictly rely on **Anchoring & Containers** for responsive scaling across devices.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [romance_affection_manager.gd](../scripts/genre_romance_affection_manager.gd) - Multi-axis (Attraction/Trust/amic_pricing_modifier.gd Attraction/Trust/Comfort) tracking and gift logic.
- [romance_date_event_system.gd](../scripts/genre_romance_date_event_system.gd) - Variety-aware dating logic with repetition penalties.
- [romance_route_manager.gd](../scripts/genre_romance_route_manager.gd) - Flag-based route branching and CG gallery persistence.

### Modular Components
- [romance_patterns.gd](../scripts/genre_romance_romance_patterns.gd) - Reusable UI helpers: Typewriter tweens and heart-burst pulses.

---

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Stats | `dictionaries`, `resources` | Tracking multi-axis affection, character profiles |
| 2. Timeline | `autoload-architecture`, `signals` | Managing time/days, triggering scheduled dates |
| 3. Narrative | `godot-dialogue-system`, `visual-novel` | Conversational branching and choice consequence |
| 4. Persistence | `godot-save-load-systems` | Saving relationship states, CG gallery, flags |
| 5. Aesthetics | `ui-theming`, `godot-tweening` | Heart-themed UI, blushing effects, emotive icons |

## Architecture Overview

### 1. Affection Manager (The Heart)
Handles complex relationship stats and gift preferences for all characters.

```gdscript
# affection_manager.gd
class_name AffectionManager
extends Node

signal milestone_reached(character_id, level)

var relationship_data: Dictionary = {} # character_id: { attraction: 0, trust: 0, comfort: 0 }

func add_affection(char_id: String, type: String, amount: int) -> void:
    if not relationship_data.has(char_id):
        relationship_data[char_id] = {"attraction": 0, "trust": 0, "comfort": 0}
    
    relationship_data[char_id][type] = clamp(relationship_data[char_id][type] + amount, -100, 100)
    check_milestones(char_id)

func get_gift_effect(char_id: String, item_id: String) -> int:
    # Logic for likes/dislikes with diminishing returns
    return 10 # Placeholder
```

### 2. Date Event System
Manages the success or failure of romantic outings.

```gdscript
# date_event_system.gd
func run_date(character_id: String, location_res: DateLocation) -> void:
    var score = 0
    # Weighted calculation
    score += relationship_data[character_id]["attraction"] * location_res.chemistry_mod
    score += relationship_data[character_id]["trust"] * location_res.safety_mod
    
    if score > location_res.success_threshold:
        play_date_outcome("SUCCESS", character_id)
    else:
        play_date_outcome("FAILURE", character_id)
```

### 3. Route Manager
Controls story branching and persistent unlocks.

```gdscript
# route_manager.gd
var unlocked_routes: Array[String] = []

func lock_in_route(char_id: String):
    # Detect conflicts with other routes here
    if flags.get("on_route"): return
    
    current_route = char_id
    flags["on_route"] = true
    unlocked_cgs.append(char_id + "_prologue")
```

## Key Mechanics Implementation

### Emotional Feedback (Juice)
Don't just change a number; show the change.

```gdscript
# ui_feedback.gd
func play_heart_burst(pos: Vector2):
    var heart = heart_scene.instantiate()
    add_child(heart)
    heart.global_position = pos
    var tween = create_tween().set_parallel()
    tween.tween_property(heart, "scale", Vector2(1.5, 1.5), 0.5)
    tween.tween_property(heart, "modulate:a", 0.0, 0.5)
```

### Time-Gated Events
Romance thrives on anticipation.

*   **Deadline Scheduling**: "Confess by June 15th or lose."
*   **Contextual Dialogue**: Characters reacting differently based on time of day or weather.

## Common Pitfalls

1.  **The "Pervert" Trap**: Forcing the player to always pick the flirtiest option to win. **Fix**: Allow "Trust" and "Friendship" paths to lead to romance eventually.
2.  **Opaque Success**: Failing a date without knowing why. **Fix**: Use character dialogue to hint at preferences ("I'm not really a fan of loud places...").
3.  **Route Conflict**: Accidentally dating two people with zero consequences. **Fix**: Implement a "Jealousy" or "Conflict Detection" system in the Route Manager.

## Godot-Specific Tips

*   **Resources for Characters**: Use `CharacterProfile` resources to store base stats, sprites, and gift preferences.
*   **RichTextLabel Animations**: Use custom BBCode for "blushing" text (pulsing pink) or "nervous" text (shaking).
*   **Dialogic Integration**: While this skill focuses on the *systems*, pairing it with Godot's **Dialogic** plugin is highly recommended for handling the actual dialogue boxes.


## Reference
- Master Skill: [godot-master](../SKILL.md)
- Sub-specialty: [godot-genre-visual-novel](genre-visual-novel.md)
