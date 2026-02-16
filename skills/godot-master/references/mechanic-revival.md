# Mechanic: Revival, Mortality & Corpse Runs

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Player Mortality**. Accessed via Godot Master.

## Architectural Thinking: The "Second Chance" Pipeline

Player death is not an error—it is a **Gameplay Event**. A Master implementation uses death as a mechanic to balance tension, risk, and narrative consequence.

### Key Concepts
- **Revival Manager**: Intercepts the "Death" moment and triggers state transitions (Respawn vs Game Over).
- **Corpse Runs**: Adding spatial value to death by dropping resources that must be retrieved (Risk).
- **Consequence Tracking**: Long-term meta-adjustment based on player failure (Dragonrot, Difficulty shifts).

## Expert Code Patterns

### 1. Duck-Type Safe Instantiation
When spawning graves/corpses, NEVER assume the scene has the correct script. Always validate methods before execution.

```gdscript
# mechanic_revival_corpse_run_dropper.gd
var instance = grave_scene.instantiate()
if not instance.has_method("setup"):
    push_error("Grave scene missing required 'setup' protocol")
    return
instance.setup(amount)
```

### 2. State-Driven Revival
Manage revival charges as a finite resource that requires specific gameplay actions (recharging at save points or via kills).

```gdscript
# mechanic_revival_revival_manager.gd
func attempt_revive() -> bool:
    if current_charges > 0:
        consume_charge()
        return true
    return false
```

## Master Decision Matrix: Death Consequence

| Model | Tension | Best For |
| :--- | :--- | :--- |
| **Soul-like** | Very High | Recovery-focused loops (Corpse Run). |
| **Rogue-lite** | High | Pure restart with meta-progression. |
| **Arcade** | Medium | Simple life counter (Lives). |

## Veteran-Only Gotchas (Never List)

- **NEVER Assume Scene Types**: `PackedScene.instantiate()` returns a generic `Node`. ALWAYS check `if instance.has_method("setup")` before calling methods to prevent runtime crashes.
- **Don't punish without feedback**: A difficulty spike is frustrating if the player doesn't know *why* it happened. Always pair consequence with UI/VFX.
- **The "Walk of Shame"**: Corpse runs add tension. The player fears losing *progress*, not just time. Ensure the path back is challenging but fair.

## Registry

- **Expert Manager**: [revival_manager.gd](../scripts/mechanic_revival_revival_manager.gd)
- **Expert Component**: [corpse_run_dropper.gd](../scripts/mechanic_revival_corpse_run_dropper.gd)
- **Expert Tracker**: [consequence_tracker.gd](../scripts/mechanic_revival_consequence_tracker.gd)
