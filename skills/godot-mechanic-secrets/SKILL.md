---
name: godot-mechanic-secrets
description: Use when implementing cheat codes, hidden interactions, or unlockable content based on player input/behavior.
---

# Secrets & Easter Eggs (Mechanics)

## Overview
This skill provides reusable components for hiding content behind specific player actions (e.g., Konami code, repetitive interaction) and managing the persistence of these discoveries.

## Core Components

### 1. Input Sequence Watcher (`input_sequence_watcher.gd`)
A node that listens for a specific sequence of `InputEvent`s.
- **Use for**: Classic "Cheat Codes", hidden debug menus, "Konami Code" implementations.
- **Behavior**: Buffers input -> Checks against target -> Emits `sequence_matched`.

### 2. Interaction Threshold Trigger (`interaction_threshold_trigger.gd`)
A component that tracks how many times an object has been interacted with.
- **Use for**: "Stop Poking Me" voice lines, breaking walls after N hits, hidden achievements.
- **Behavior**: Counts signals -> Emits `threshold_reached` at specific counts.

### 3. Secret Persistence (`secret_persistence_handler.gd`)
A standardized way to save/load "Unlocked" states.
- **Use for**: Ensuring a player doesn't have to re-enter a code every session.
- **Behavior**: Wraps `ConfigFile` to save boolean flags to `user://secrets.cfg`.

## Usage Example (Cheat Code)

```gdscript
# In your Game Manager or Player Controller
@onready var cheat_watcher = $InputSequenceWatcher

func _ready():
    # Define UP, UP, DOWN, DOWN...
    cheat_watcher.sequence = [
        "ui_up", "ui_up", "ui_down", "ui_down"
    ]
    cheat_watcher.sequence_matched.connect(_on_cheat_unlocked)

func _on_cheat_unlocked():
    print("God Mode Enabled!")
    SecretPersistence.unlock_secret("god_mode")
```

## Anti-Patterns
- **NEVER Hardcode Input Checks**: NEVER use `Input.is_action_just_pressed` in `_process` for sequences. It is frame-dependent and brittle. ALWAYS use an event-based buffer.
- **NEVER Pollute PlayerPrefs**: NEVER save hidden unlockables in the user's main `settings.cfg` (resolution, volume). If the user deletes settings to fix a graphic glitch, they shouldn't lose their unlocked cheats. Use `user://secrets.cfg`.
- **NEVER Trust Client Inputs for Competitive Secrets**: If your secret grants a competitive advantage (e.g., in multiplayer), NEVER validate it solely on the client.
