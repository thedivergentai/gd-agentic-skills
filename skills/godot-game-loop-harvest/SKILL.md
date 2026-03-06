---
name: godot-game-loop-harvest
description: Data-driven resource harvesting system (mining, logging, foraging) for Godot 4. Use when implementing gathering mechanics with tool/tier validation, health depletion, item spawning, and persistence.
---

# Godot Game Loop: Harvest

Implement decoupled, data-driven gathering mechanics. This system handles tool validation, depletion, and respawning.

## 1. Component Reference

| Component | Asset | Description |
| :--- | :--- | :--- |
| **Resource Data** | [resource_data.gd](assets/resource_data.gd) | `Resource`: Defines health, yield, and tool requirements. |
| **Tool Data** | [harvest_tool_data.gd](assets/harvest_tool_data.gd) | `Resource`: Defines damage, type, and tier. |
| **Harvestable Node** | [harvestable_node.gd](assets/harvestable_node.gd) | `StaticBody3D`: The world interaction entity. |
| **Respawn Manager** | [harvest_respawn_manager.gd](assets/harvest_respawn_manager.gd) | `Node`: (Singleton) Manages world persistence. |
| **Inventory Manager**| [harvest_inventory_manager.gd](assets/harvest_inventory_manager.gd) | `Node`: Hub for resource collection. |

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

## 4. Engineering Standards
- **Physics**: Depleted nodes shift to **Layer 16** (Inactive) and hide while respawning.
- **Yield Logic**: Quantity is randomized based on the resource's `yield_range`.
- **Feedback**: Tactile feedback via `mesh_to_shake` is essential for game "juice."

## 5. Verification Checklist
- [ ] **Shake**: Mesh shakes slightly upon a valid hit.
- [ ] **Validation**: Emits `interaction_failed` if tool/tier requirements are unmet.
- [ ] **Depletion**: Node hides and collision disables at 0 health.
- [ ] **Drops**: Spawns `item_scene` at the node's position upon harvest.
- [ ] **Respawn**: Node reappears and re-enables collision after `respawn_time`.
