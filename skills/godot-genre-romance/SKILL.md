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

## NEVER Do in Romance Games

- **NEVER create "Vending Machine" romance** — If giving 10 gifts always equals a confession, the characters feel like objects. ALWAYS incorporate variables like current mood, timing, and stat thresholds (e.g., "Must have 10 Courage to ask out").
- **NEVER use 100% opaque stats** — If the player doesn't know *why* they failed a date, they feel cheated. ALWAYS provide subtle feedback or visible "Relationship Screens" (e.g., hearts pulsing, trust bars filling).
- **NEVER use binary Affection (Love/Hate)** — Real relationships are complex. Use multi-axis stats such as **Attraction** (physical/chemistry), **Trust** (emotional safety), and **Comfort** (familiarity) for deeper simulation.
- **NEVER use the "Same Date Order" trap** — Repeating the exact same date sequence for every character makes the game feel repetitive. ALWAYS vary date locations, activities, and dialogue structures per love interest.
- **NEVER forget "Missable" Milestones** — If a player misses the "Valentine's Day" event because they were working, that's a meaningful (if painful) consequence. Don't force every event to happen regardless of player choices.
- **NEVER ignore NPC Autonomy** — If an NPC only exists for the player, they feel hollow. Give them their own schedules, goals, and the ability to *reject* the player if specific conditions (like low trust) aren't met.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
- Sub-specialty: [godot-genre-visual-novel](../godot-genre-visual-novel/SKILL.md)
