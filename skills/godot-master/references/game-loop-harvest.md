---
name: godot-game-loop-harvest
description: Data-driven resource harvesting system (mining, logging, foraging) for Godot 4. Use when implementing gathering mechanics with tool/tier validation, health depletion, item spawning, and persistence.
---

# Godot Game Loop: Harvest

Implement decoupled, data-driven gathering mechanics. This system handles tool validation, depletion, and respawning.

## 1. Component Reference

| Component | Asset | Description |
| :--- | :--- | :--- |
| **Resource Data** | [resource_data.gd](../scripts/game_loop_harvest_resource_data.gd) | `Resource`: Defines health, yield, and tool requirements. |
| **Tool Data** | [harvest_tool_data.gd](../scripts/game_loop_harvest_harvest_tool_data.gd) | `Resource`: Defines damage, type, and tier. |
| **Harvestable Node** | [harvestable_node.gd](../scripts/game_loop_harvest_harvestable_node.gd) | `StaticBody3D`: The world interaction entity. |
| **Respawn Manager** | [harvest_respawn_manager.gd](../scripts/game_loop_harvest_harvest_respawn_manager.gd) | `Node`: (Singleton) Manages world persistence. |
| **Inventory Manager**| [harvest_inventory_manager.gd](../scripts/game_loop_harvest_harvest_inventory_manager.gd) | `Node`: Hub for resource collection. |

## 2. Implementation Guide

### Step 1: Resource Setup
- Create a `HarvestResourceData` resource in the inspector.
- Configure `Required Tool Type` (e.g., "pickaxe", "axe") and `Required Tier`.
- Set `Yield Range` (Vector2i) and optional `Item Scene` for physical drops.

### Step 2: Node Configuration
- Attach `harvestable_node.gd` to a `StaticBody3D` node.
- Assign the `ResourceData` from Step 1.
- Assign a child `Node3D` (e.g., a Mesh) to `mesh_to_shake` for visual feedback.
- **Physics**: Ensure the node is on **Layer 1** for interaction.

### Step 3: Global Systems (Recommended)
- Add `harvest_respawn_manager.gd` as an **Autoload** named `HarvestRespawnManager`.
- The `HarvestableNode` will automatically use this manager if it is found at `/root/HarvestRespawnManager`.

## 3. Interaction & Signals

### Calling Hits
When a player interacts (e.g., via RayCast), call `apply_hit(tool_data)`.

```gdscript
if collider is HarvestableNode:
    collider.apply_hit(player_tool)
```

### Signal Map
| Signal | Payload | Integration |
| :--- | :--- | :--- |
| `harvested` | `(data, amount)` | Connect to `InventoryManager.add_resource`. |
| `took_damage` | `(curr, max)` | Connect to a Progress Bar or Damage Popups. |
| `interaction_failed`| `(reason: String)` | Handles `"wrong_tool"` or `"low_tier"` UI feedback. |

## NEVER Do

- **NEVER use float variables to store massively accumulated harvest resources** — Large floats lose precision, which can lead to "missing" resources in idle/clicker games. Always use `int` for core counts.
- **NEVER process gathering logic in _process() without multiplying rates by delta** — If you don't use `delta`, the harvesting speed will fluctuate wildly based on the player's hardware performance/framerate.
- **NEVER run heavy array mathematics for thousands of resources on the main thread** — This will cause micro-stutters. Distribute heavy calculations using `WorkerThreadPool`.
- **NEVER leave a gathering game running at full GPU utilization** — For UI-heavy harvest games, enable `OS.low_processor_usage_mode` to drastically reduce battery drain on mobile/laptops.
- **NEVER trust OS.get_ticks_msec() for offline progress** — This only tracks system uptime. Rely on `Time.get_unix_time_from_system()` to calculate real-world time passed between sessions.
- **NEVER use Timer nodes for precise audio-visual harvesting synchronization** — Timer nodes are subject to framerate variations. For frame-perfect sync, use code-based timers or the animation system.
- **NEVER couple your resource logic directly to UI counters** — Use a signal bus or event system to notify the UI of changes, keeping the game logic decoupled from the presentation.
- **NEVER constantly instantiate and destroy Label nodes for "floating numbers"** — Frequent allocation/deallocation leads to memory fragmentation. Use an object pool for damage/harvest popups.
- **NEVER modify a globally shared Resource without calling duplicate()** — If you modify a shared `Resource` (like a base crop yield), every instance using that resource will be updated. Use `duplicate(true)`.
- **NEVER access shared harvest data from background threads without a Mutex** — Simultaneous access will eventually corrupt your inventory data. Always use a `Mutex` to lock sensitive blocks.
- **NEVER hardcode yield values in your gathering scripts** — Use exports and custom `Resource` files so designers can balance the economy without touching the code.
- **NEVER use queue_free() on a harvested node before the VFX/SFX finish** — You'll cut off the "juice." Hide the mesh and disable collision, then `queue_free()` once the effect signals completion.
- **NEVER check tool requirements via string comparisons if possible** — Use enums or class types. Strings are prone to typos and are slower for high-frequency checks.
- **NEVER neglect to save the UNIX timestamp on exit** — If you forget this, you lose the ability to calculate offline earnings when the player returns.
- **NEVER scale collision shapes non-uniformly for harvestable objects** — This breaks the underlying physics calculations. Adjust the shape resource dimensions instead.

---

## Available Scripts

> **MANDATORY**: Read the appropriate script before implementing the corresponding pattern.

### [harvest_loop_patterns.gd](../scripts/game_loop_harvest_harvest_loop_patterns.gd)
Expert patterns for idle optimization, UNIX-based offline gains, and threaded resource processing.

### [resource_data.gd](../scripts/game_loop_harvest_resource_data.gd)
`Resource` container: Defines health, yield, and tool requirements for a harvestable object.

### [harvestable_node.gd](../scripts/game_loop_harvest_harvestable_node.gd)
`StaticBody3D`: The world interaction entity that handles hits, shakes, and depletion.
