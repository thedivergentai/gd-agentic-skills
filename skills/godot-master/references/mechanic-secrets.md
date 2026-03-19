---
name: godot-mechanic-secrets
description: Use when implementing cheat codes, hidden interactions, or unlockable content based on player input/behavior.
---

# Secrets & Easter Eggs (Mechanics)

## Overview
This skill provides reusable components for hiding content behind specific player actions (e.g., Konami code, repetitive interaction) and managing the persistence of these discoveries.

## Core Components

### [secret_meta_persistence.gd](../scripts/mechanic_secrets_secret_meta_persistence.gd)
Expert logic for saving global unlocks and discovery flags across all save profiles.

### [secret_visibility_detector.gd](../scripts/mechanic_secrets_secret_visibility_detector.gd)
View-dependent hidden wall detection using optimized Dot Product calculations.

### [secret_sequence_combo_matcher.gd](../scripts/mechanic_secrets_secret_sequence_combo_matcher.gd)
Professional time-sensitive input buffer for detecting complex cheat combos and sequences.

### [secret_interaction_spam_tracker.gd](../scripts/mechanic_secrets_secret_interaction_spam_tracker.gd)
Logic for tracking repetitive player actions to trigger curiosity-based Easter Eggs.

### [secret_audio_environment_occluder.gd](../scripts/mechanic_secrets_secret_audio_environment_occluder.gd)
Spatial logic for dynamically adjusting AudioBus effects in sealed or hidden areas.

### [secret_progress_threshold_unlocker.gd](../scripts/mechanic_secrets_secret_progress_threshold_unlocker.gd)
Percentage-based unlocker for meta-content and 'True Ending' triggers.

### [secret_random_encounter_spawner.gd](../scripts/mechanic_secrets_secret_random_encounter_spawner.gd)
Weighted random system for rarest-tier entities and secret vendor encounters.

### [secret_lockout_cheat_guard.gd](../scripts/mechanic_secrets_secret_lockout_cheat_guard.gd)
Anti-brute-force lockout manager to protect secret integrity.

### [secret_vfx_discovery_glimmer.gd](../scripts/mechanic_secrets_secret_vfx_discovery_glimmer.gd)
Subtle procedural visual cues for hinting at hidden interactables.

### [secret_konami_legacy_code.gd](../scripts/mechanic_secrets_secret_konami_legacy_code.gd)
Specialized implementation of the iconic Konami code using the buffer matcher.

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

## NEVER Do (Expert Secret Rules)

### Discovery & Triggers
- **NEVER hardcode input checks in `_process`** — Frame-dependent polling is unreliable for fast combos. Always use an event-based buffer like `secret_sequence_combo_matcher.gd`.
- **NEVER use complex Raycasts for 'LookingAt' secrets** — Physics raycasts are expensive if every wall is checking. Use the Dot Product method in `secret_visibility_detector.gd` for overhead efficiency.
- **NEVER make 'Hidden Walls' identical to real walls** — Players need a subtle "Glimmer" or texture discrepancy. Total invisibility isn't a secret; it's a bug to the player.

### Persistence & Meta
- **NEVER save "Secrets Found" in the main Save Slot** — If the player deletes their save to try a different build, their meta-progress (Gallery, Achievement flags) should persist. Use `secret_meta_persistence.gd`.
- **NEVER trust client-side cheat validation in Peer-to-Peer** — If a secret grants a stat boost, other peers should validate the "Unlock" to prevent simple memory-editing cheats.
- **NEVER use `PlayerPrefs` (Godot's equivalent of Settings) for secrets** — Use a dedicated `user://secrets.cfg`.

### UX & Anti-Brute Force
- **NEVER allow unlimited rapid-fire cheat attempts** — A simple macro can brute-force a 4-button combo in seconds. Use `secret_lockout_cheat_guard.gd` to add a penalty for excessive failures.
- **NEVER trigger a secret without an 'Aha!' audio/visual cue** — The reward for finding a secret is the *feeling* of discovery. Use `secret_audio_environment_occluder.gd` to change the atmosphere.

---

## Reference
- Master Skill: [godot-master](../SKILL.md)
