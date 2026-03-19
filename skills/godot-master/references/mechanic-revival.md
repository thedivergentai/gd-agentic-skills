---
name: godot-mechanic-revival
description: Use when implementing player death, resurrection, or "second chance" mechanics.
---

# Revival & Resurrection Mechanics

## Overview
This skill provides a robust framework for handling player mortality and return. It moves beyond simple "Game Over" screens to integrated risk/reward systems like those found in *Sekiro*, *Hades*, or *Dark Souls*.

## NEVER Do (Expert Revival Rules)

### Lifecycle & State
- **NEVER respawn the player with existing velocity** — Always zero out `velocity` and `angular_velocity` in `revival_state_reset_guard.gd` or the player will fly into a wall upon respawning.
- **NEVER trust the nearest checkpoint by distance** — Always use a 'Progress Index' (`revival_checkpoint_validator.gd`). Players in non-linear games may wander back to the start area; don't downgrade their respawn point.
- **NEVER skip 'Invincibility Frames' (I-frames)** — Respawning inside a hazard or near an enemy without a 2s invincibility buffer leads to "Death Loops" and player frustration.

### Persistence & Data
- **NEVER save checkpoints solely in RAM** — If the game crashes, the player loses progress. Use `revival_checkpoint_persistence.gd` to write to `user://` immediately.
- **NEVER hardcode checkpoint coordinates** — Use `Marker3D` or `Area3D` nodes in the scene. Hardcoded coords break as soon as level geometry changes.
- **NEVER delete the player node on death** — `queue_free()`ing the player breaks UI refs and references from enemies. Disable processing, hide the mesh, and 'Revive' the existing instance instead.

### UX & Pacing
- **NEVER respawn instantly** — An instant snap is disorienting. Always use a 1-2s delay with a screen fade or death animation to allow the player to process the failure.
- **NEVER reset the entire world on player death** — In modern design, opened doors and collected unique items should stay persisted. Use a bitmask in the checkpoint resource to track 'World Progress'.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [revival_global_manager.gd](../scripts/mechanic_revival_revival_global_manager.gd)
Expert singleton for managing the global respawn loop and death transitions.

### [revival_checkpoint_persistence.gd](../scripts/mechanic_revival_revival_checkpoint_persistence.gd)
Resource-based system for saving last checkpoint and world state to disk.

### [revival_health_restitution.gd](../scripts/mechanic_revival_revival_health_restitution.gd)
Professional I-frame and health replenishment logic for post-revive stability.

### [revival_soul_grave.gd](../scripts/mechanic_revival_revival_soul_grave.gd)
Expert 'Soul Retrieval' mechanic for spawning graves at death coordinates.

### [revival_checkpoint_validator.gd](../scripts/mechanic_revival_revival_checkpoint_validator.gd)
Progress-aware validator that prevents backtracking from overwriting newer checkpoints.

### [revival_death_timer.gd](../scripts/mechanic_revival_revival_death_timer.gd)
Professional respawn delay manager with UI and animation hooks.

### [revival_ghost_mode.gd](../scripts/mechanic_revival_revival_ghost_mode.gd)
Expert 'Spirit World' transition logic involving collision layer swapping.

### [revival_state_reset_guard.gd](../scripts/mechanic_revival_revival_state_reset_guard.gd)
Essential utility for purging velocity and state locks upon player respawn.

### [revival_checkpoint_visuals.gd](../scripts/mechanic_revival_revival_checkpoint_visuals.gd)
Material-swapping logic for providing clear 'Active' feedback to players.

### [revival_auto_save_manager.gd](../scripts/mechanic_revival_revival_auto_save_manager.gd)
Automatic save-trigger logic for ensuring checkpoint persistence.

---

## Reference
- Master Skill: [godot-master](../SKILL.md)
