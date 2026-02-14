> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Combat Systems**. Accessed via Godot Master.

# Combat System

Expert guidance for building flexible, component-based combat systems with robust damage pipelines and hit-stop feedback.

## Available Scripts

### [hitbox_hurtbox.gd](../scripts/godot-combat-system_hitbox_hurtbox.gd)
Component-based system for high-fidelity combat. Includes built-in support for hit-stop (screen freeze), knockback calculation, and collision-based damage.


## NEVER Do

- **NEVER use direct property access for damage (`target.health -= 10`)** — This bypasses armor and event logs. Use the `DamageData` + `HealthComponent` pattern for all interactions.
- **NEVER forget Invincibility Frames (i-frames)** — Multi-hit attacks will deal damage every single frame without a cooldown period. Standard i-frames last 0.1s to 0.5s.
- **NEVER keep hitboxes active permanently** — Toggle `monitoring` or `monitorable` via AnimationPlayer tracks to ensure damage only occurs when intended.
- **NEVER use Groups for hitbox filtering** — Rely on Physics Layers and Masks. Groups do not respect the physics engine's internal efficiency and can lead to bugs.
- **NEVER emit signals with raw numbers** — Always wrap damage information in a `DamageData` object to maintain context (source, type, critical status, etc.).

---

## The Damage Pipeline

### 1. DamageData (Strategy/DTO)
A small object containing `amount`, `source`, `damage_type`, and `knockback` vector.

### 2. Hitbox (The Attacker)
An `Area2D/3D` that detects overlaps. It prepares a `DamageData` object and passes it to the `Hurtbox` on impact.

### 3. Hurtbox (The Receiver)
An `Area2D/3D` that listens for `Hitbox` entries. It relays the `DamageData` to the `HealthComponent`.

### 4. HealthComponent (The Logic)
A `Node` that manages the `current_health` variable, handles resistances, and emits `died` or `health_changed` signals.

---

## Combo System Logic
Maintain a `combo_buffer` array. Each attack appends its ID. If the sequence matches a predefined combo (e.g., L, L, H) within the `combo_window` (0.5s), execute the special finisher.

## Damage Popups
Use a `Label` or `Label3D` managed by a `Tween`. Animate the popup upwards while fading the alpha to zero. Scale and color the text based on `DamageData.is_critical`.

## Combat State Management
Use a state machine to track if the character is `IDLE`, `ATTACKING`, or `STUNNED`. This prevents "gliding" (moving while attacking) and ensures proper animation playback.

## Reference
- [Godot Docs: Area2D/3D](https://docs.godotengine.org/en/stable/classes/class_area2d.html)
- [Godot Docs: Using Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
