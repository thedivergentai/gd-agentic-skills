# Harvest Loop: Resource Gathering

> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Harvesting Loops**. Accessed via Godot Master.

## Architectural Thinking: The "Value-Node" Pattern

A Master implementation treats harvestable objects as **Nodes of Persistence**. These aren't just objects you hit; they are part of a world-state that manages its own regrowth and yield variability.

### Core Responsibilities
- **Node**: Handles individual health and interaction logic.
- **ResourceData**: Defines the "DNA" of the resource (hardness, yield, tool types).
- **InventoryManager**: Global tracker for gathered materials.

## Expert Code Patterns

### 1. Tool-Specific Validation
```gdscript
# game_loop_harvest_node.gd snippet
func apply_hit(damage, tool_type):
    if resource_data.required_tool_type != tool_type:
        _play_tink_sound() 
        return
```

### 2. Layer-Based Depletion
Instead of `queue_free()`, use **Layer Swapping**. This keeps the node in memory for respawn logic while making it invisible.

### 3. Inventory Accumulation
Use a dedicated manager to decouple gathering from your main inventory system.
```gdscript
# game_loop_harvest_inventory.gd
func add_resource(resource, amount):
    inventory[resource.display_name] += amount
```

## NEVER Do
- **NEVER hardcode yield values** in the script. Use `Resource` files.
- **NEVER forget the "Hit Juice"**. Shake the mesh and play sounds.
- **NEVER use `RayCast` for mining without a distance check**. 

## Registry
- **Expert Component**: [game_loop_harvest_node.gd](../scripts/game_loop_harvest_node.gd)
- **Expert Component**: [game_loop_harvest_data.gd](../scripts/game_loop_harvest_data.gd)
- **Expert Component**: [game_loop_harvest_inventory.gd](../scripts/game_loop_harvest_inventory.gd)
