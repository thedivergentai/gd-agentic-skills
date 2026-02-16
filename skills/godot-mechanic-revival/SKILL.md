---
name: godot-mechanic-revival
description: Use when implementing player death, resurrection, or "second chance" mechanics.
---

# Revival & Resurrection Mechanics

## Overview
This skill provides a robust framework for handling player mortality and return. It moves beyond simple "Game Over" screens to integrated risk/reward systems like those found in *Sekiro*, *Hades*, or *Dark Souls*.

## Core Systems

### 1. Revival Manager (`revival_manager.gd`)
The central state machine for death.
- **Role**: Intercepts death signals. Determines if a revival is possible.
- **Key Concept**: `RevivalCharges`.
    -   *Sekiro Style*: 1 charge, requires cooldown or kills to recharge.
    -   *Arcade Style*: 3 Lives, then Game Over.

### 2. Corpse Run Dropper (`corpse_run_dropper.gd`)
A spatial component for retrieving lost assets.
- **Role**: Spawns a physical object at the death location containing X% of the player's resources (Gold, Souls, XP).
- **Behavior**: On Death -> Calculate Loss -> Spawn Grave -> Save Grave Data.

### 3. Consequence Tracker (`consequence_tracker.gd`)
A meta-game balancer.
- **Role**: Tracks how many times the player has died or revived.
- **Application**:
    -   *Dynamic Difficulty*: Lower enemy HP after 10 deaths.
    -   *Narrative Penalty*: "Dragonrot" (NPCs get sick) or World Tendency shifts.

## Usage Example

```gdscript
# On Player Health Component
func take_damage(amount):
    health -= amount
    if health <= 0:
        if RevivalManager.can_revive():
            RevivalManager.request_revive_ui()
        else:
            GameManager.trigger_game_over()
```

## Design Patterns for Balance
- **The "Freebie"**: Allow 1 mistake per checkpoint. Prevents frustration from cheap deaths.
- **The "Cost"**: Reviving shouldn't be free. It consumes a resource (Charge), or costs meta-currency.
- **NEVER Assume Scene Types**: `PackedScene.instantiate()` returns a generic `Node`. ALWAYS check `if instance.has_method("setup")` before calling methods to prevent runtime crashes.
- **Don't punish without feedback**: A difficulty spike is frustrating if the player doesn't know *why* it happened. Always pair consequence with UI/VFX.
- **The "Walk of Shame"**: Corpse runs add tension. The player fears losing *progress*, not just time.
