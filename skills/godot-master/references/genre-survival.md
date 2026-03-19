---
name: godot-genre-survival
description: "Expert blueprint for survival games (Minecraft, Don't Starve, The Forest, Rust) covering needs systems, resource gathering, crafting recipes, base building, and progression balancing. Use when building open-world survival, crafting-focused, or resource management games. Keywords survival, needs system, crafting, inventory, hunger, resource gathering, base building."
---

# Genre: Survival

Resource scarcity, needs management, and progression through crafting define survival games.

## NEVER Do (Expert Anti-Patterns)

### Physiology & Needs
- NEVER use constant "Needs" decay; strictly scale with activity (e.g., **Sprinting** drains hunger 3x faster than idling).
- NEVER use Instant Death for starvation/dehydration; strictly trigger gradual HP drain and provide distinct visual/audio warnings.
- NEVER use float timers for exact life-critical checks; strictly use `is_equal_approx()` or `<=` to prevent 0.0 precision misses.
- NEVER represent world time/day cycles within UI scripts; strictly use an **AutoLoad (Singleton)** to decouple state from visuals.

### Gathering & Inventory
- NEVER make gathering tedious without progression; strictly implement **Tiered Tool Scaling** (e.g., Stone Axe = 1 wood/hit, Steel Axe = 5 wood/hit) to reward technical advancement.
- NEVER allow infinite inventory stacking; strictly use **Weight Capacity** or strict **Stack Limits** (e.g., 64 items) to force strategic resource management.
- NEVER force players to "Guess" crafting recipes; strictly use a **Discovery System** where recipes unlock upon acquiring materials.
- NEVER forget to **duplicate(true)** a shared Resource (like Item Durability); otherwise, all instances will break simultaneously.
- NEVER store heavy item/crafting definitions in Node properties; strictly use custom **Resource** containers for lightweight data.

### World & Performance
- NEVER spawn threats at Respawn Points; strictly enforce a **Safe Zone radius** (Beds/Spawn) where enemy spawning is prohibited.
- NEVER instance 10,000 individual `MeshInstance3D` nodes for foliage; strictly use **MultiMeshInstance3D** for batched draw calls.
- NEVER load massive world chunks synchronously; strictly use `ResourceLoader.load_threaded_request()` to prevent hitches.
- NEVER save complex dictionaries to standard text files; strictly use binary serialization for speed and size efficiency.
- NEVER run procedural terrain/noise algorithms on the main thread; strictly offload to the **WorkerThreadPool**.
- NEVER hardcode massive crafting tables in GDScript; strictly use `ConfigFile` or JSON for easy balancing and modding.

---

## 🛠 Expert Components (scripts/)

### Original Expert Patterns
- [inventory_slot_resource.gd](../scripts/genre_survival_inventory_slot_resource.gd) - Data-driven inventory slot model using Resources for seamless serialization and durability tracking.
- [survival_patterns.gd](../scripts/genre_survival_survival_patterns.gd) - 10 Essential Survival Expert Patterns (Decay scaling, Environment tweens, MultiMesh optimization).

### Modular Components
- [interactable.gd](../scripts/genre_survival_interactable.gd) - Universal interface for harvesting, picking up items, and world triggers.
- [inventory_data.gd](../scripts/genre_survival_inventory_data.gd) - Core business logic for grid-based inventories and stacking.
- [inventory_slot_data.gd](../scripts/genre_survival_inventory_slot_data.gd) - Lightweight data container for UI-to-Logic inventory communication.
- [inventory_data.gd](../scripts/genre_survival_inventory_data.gd) - High-performance Resource-based storage with stack limits and metadata support.
- [inventory_data.gd](../scripts/genre_survival_inventory_data.gd) - Master item definition for weight, stack-size, and consumption effects (Resource-based).

---

| Phase | Skills | Purpose |
|-------|--------|---------|
| 1. Data | `resources`, `custom-resources` | Item data (weight, stack size), Recipes |
| 2. UI | `grid-containers`, `drag-and-drop` | Inventory management, crafting menu |
| 3. World | `tilemaps`, `noise-generation` | Procedural terrain, resource spawning |
| 4. Logic | `state-machines`, `signals` | Player stats (Needs), Interaction system |
| 5. Save | `file-system`, `json-serialization` | Saving world state, inventory, player stats |

## Architecture Overview

### 1. Item Data (Resource-based)
Everything in the inventory is an Item.

```gdscript
# item_data.gd
extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var icon: Texture2D
@export var max_stack: int = 64
@export var weight: float = 1.0
@export var consumables: Dictionary # { "hunger": 10, "health": 5 }
```

### 2. Inventory System
A grid-based data structure.

```gdscript
# inventory.gd
extends Node

signal inventory_updated

var slots: Array[ItemSlot] = [] # Array of Resources or Dictionaries
@export var size: int = 20

func add_item(item: ItemData, amount: int) -> int:
    # 1. Check for existing stacks
    # 2. Add to empty slots
    # 3. Return amount remaining (that couldn't fit)
    pass
```

### 3. Interaction System
A universal way to harvest, pickup, or open things.

```gdscript
# interactable.gd
extends Area2D
class_name Interactable

@export var prompt: String = "Interact"

func interact(player: Player) -> void:
    _on_interact(player)

func _on_interact(player: Player) -> void:
    pass # Override this
```

## Key Mechanics Implementation

### Needs System
Simple float values that deplete over time.

```gdscript
# needs_manager.gd
var hunger: float = 100.0
var thirst: float = 100.0
var decay_rate: float = 1.0

func _process(delta: float) -> void:
    hunger -= decay_rate * delta
    thirst -= decay_rate * 1.5 * delta
    
    if hunger <= 0:
        take_damage(delta)
```

### Crafting Logic
Check if player has ingredients -> Remove ingredients -> Add result.

```gdscript
func craft(recipe: Recipe) -> bool:
    if not has_ingredients(recipe.ingredients):
        return false
        
    remove_ingredients(recipe.ingredients)
    inventory.add_item(recipe.result_item, recipe.result_amount)
    return true

### 4. Tiered Tool Scaling
Scaling resource yield with tool quality (`item_data.gd` metadata):
- **Stone Axe**: 1 yield per hit, 3s harvest time.
- **Steel Axe**: 5 yield per hit, 1.5s harvest time.
- **Auto-Saw**: Constant yield stream while within proximity.

### 5. Spawn Safe Zones
Preventing "Spawn Camping" via check:
```gdscript
func get_spawn_point() -> Vector3:
    var point = find_random_point()
    for bed in get_tree().get_nodes_in_group("player_beds"):
        if point.distance_to(bed.global_position) < safe_radius:
            return get_spawn_point() # Re-roll
    return point
```
```

## Godot-Specific Tips

*   **TileMaps**: Use `TileMap` (Godot 3) or `TileMapLayer` (Godot 4) for the world.
*   **FastNoiseLite**: Built-in noise generator for procedural terrain (trees, rocks, biomes).
*   **ResourceSaver**: Save the `Inventory` resource directly to disk if it's set up correctly with `export` vars.
*   **Y-Sort**: Essential for top-down 2D games so player sorts behind/in-front of trees correctly.

## Common Pitfalls

1.  **Tedium**: Harvesting takes too long. **Fix**: Scale resource gathering with tool tier (Stone Axe = 1 wood, Steel Axe = 5 wood).
2.  **Inventory Clutter**: Too many unique items that don't stack. **Fix**: Be generous with stack sizes and storage options.
3.  **No Goals**: Player survives but gets bored. **Fix**: Add a tech tree or a "boss" to work towards.


## Reference
- Master Skill: [godot-master](../SKILL.md)
