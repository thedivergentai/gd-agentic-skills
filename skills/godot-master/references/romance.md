> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Romance & Relationship Systems**. Accessed via Godot Master.

# Romance & Relationship Architecture

Mastering the "Affection Economy"—the management of player time and resources to influence NPC attraction, trust, and intimacy.

## 1. The Affection Economy Loop
1.  **Meet**: Encounter level love interests; establish baseline rapport.
2.  **Date**: Structured events to learn preferences and test compatibility.
3.  **Deepen**: Invest resources (time, gifts, choices) to increment relationship axis.
4.  **Branch**: Major milestones unlock character-specific "Routes".
5.  **Resolve**: Conclusion (Good/Normal/Bad) based on cumulative stat quality.

## 2. Multi-Axis Relationship Matrix

> [!IMPORTANT]
> Avoid binary "Like/Hate" counters. Use a three-axis model for believable NPC dynamics.

| Axis | Focus | Impact |
| :--- | :--- | :--- |
| **Attraction** | Physical/Chemistry | Unlocks romantic dates, flirting success |
| **Trust** | Emotional Safety | Required for deep secrets, vulnerability, and True Endings |
| **Comfort** | Familiarity | Reduces penalty for "bad" choices, unlocks domestic events |

## 3. Expert "Never" List (Genre Integrity)

- **NEVER create "Vending Machine" romance** — NPCs are not objects. Incorporate variables like mood, timing, and internal stat thresholds.
- **NEVER use 100% opaque stats** — Provide subtle feedback (blushing, heart UI, pulsing text) or a relationship overview screen.
- **NEVER use the "Same Date Order" trap** — Repeating the exact same sequence for every character destroys immersion. 
- **NEVER ignore NPC Autonomy** — Give NPCs schedules and the ability to *reject* the player based on low trust or conflicting events.

## 4. Architectural Implementation

### Relationship Tracker
Handles multi-axis calibration and gift preference logic.
- **Standard**: [romance_affection_manager.gd](../scripts/romance_affection_manager.gd)

### Event & Date Logic
Manages weighted success/failure and prevented date repetition.
- **Standard**: [romance_date_event_system.gd](../scripts/romance_date_event_system.gd)

### Route & Flag Management
Controls story branching, CG unlocks, and ending determination.
- **Standard**: [romance_route_manager.gd](../scripts/romance_route_manager.gd)

## 5. Expert Code Snippets

### Variety-Aware Date Logic
```gdscript
# Apply variety penalty if same location repeated recently
if history.size() > 0 and history[-1] == location_data["id"]:
    score *= 0.7 # 30% penalty for repetitiveness
    date_interaction.emit(character_id, "repetitive_date_complaint")
```

### Milestone Signals
```gdscript
signal milestone_reached(character_id, level)
# Fire milestones based on thresholds (e.g. 20, 50, 80) to unlock route transitions
```

## 6. Godot-Specific Design
- **Character Resources**: Create `CharacterProfile` resources for base stats and gift likes/dislikes.
- **RichTextLabel Juicing**: Use custom BBCode for "blushing" (pulsing pink) or "nervous" (shaking) text.
- **Persistence**: Store CG gallery unlocks in a separate global save file (e.g., `user://gallery.save`).
