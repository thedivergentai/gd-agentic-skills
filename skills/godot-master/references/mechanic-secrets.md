# Mechanic Secrets: Hidden Interactions & Cheat Codes

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Secrets**. Accessed via Godot Master.

## Architectural Thinking: The "Secret" Economy

At a Master level, secrets are not just "Easter Eggs"—they are a layer of **Intentional Obfuscation** used for:
1.  **Direct Debugging**: Hidden menus bypass complex UI flows for developers.
2.  **Viral Engagement**: "Konami Code" style discovery as community meta-game.
3.  **Progression Bypassing**: Allowing legacy players to skip content.

## Expert Code Patterns

### 1. Robust Input Sequence Buffering
Master-level sequence implementation avoids `Input.is_action_just_pressed()` polling in `_process`.

```gdscript
# mechanic_secrets_input_sequence_watcher.gd
# Use event-based buffering with a strict timeout to ensure clean input intent.
func _input(event: InputEvent) -> void:
    if not event.is_pressed() or event.is_echo(): return
    
    _timer.start(timeout) # Keep combo alive
    _buffer.append(matched_action)
    
    if _buffer == target:
        sequence_matched.emit()
```

### 2. Isolated Secret Persistence
NEVER pollute `settings.cfg` or `save_game.dat` with secret flags. Keep a dedicated configuration for "Meta-Discovery".

```gdscript
# mechanic_secrets_secret_persistence_handler.gd
var config = ConfigFile.new()
const PATH = "user://secrets.cfg" # Keep separate from volatile save data
```

## Master Decision Matrix: Secret Implementation

| Pattern | Best For | Trade-off |
| :--- | :--- | :--- |
| **Input Sequence** | Cheats / Debug Menus | Rigid. Requires player knowledge. |
| **Interaction Threshold** | "Poking" content / Wall Hitting | Narrative "Juice". Predictable. |
| **Environment Trigger** | Classic 3-pillar / Lever puzzles | Physical space required. |

## Veteran-Only Gotchas (Never List)

- **NEVER Hardcode Input Checks**: Polling `Input.is_action_just_pressed` in `_process` for sequences is frame-dependent and brittle. Always use a signal-driven buffer.
- **NEVER Pollute Player Settings**: Resolved resolution/volume settings are volatile; secret unlocks are permanent "discovery" data. Use `user://secrets.cfg`.
- **NEVER Use Cleartext for Competitive Secrets**: If secrets grant multiplayer/leaderboard advantages, store them as hashes or server-side only.

## Registry

- **Expert Component**: [input_sequence_watcher.gd](../scripts/mechanic_secrets_input_sequence_watcher.gd)
- **Expert Component**: [interaction_threshold_trigger.gd](../scripts/mechanic_secrets_interaction_threshold_trigger.gd)
- **Expert Handler**: [secret_persistence_handler.gd](../scripts/mechanic_secrets_secret_persistence_handler.gd)
