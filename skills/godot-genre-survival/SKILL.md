---
name: godot-genre-survival
description: "Expert blueprint for survival games (Minecraft, Don't Starve, The Forest, Rust) covering needs systems, resource gathering, crafting recipes, base building, and progression balancing. Use when building open-world survival, crafting-focused, or resource management games. Keywords survival, needs system, crafting, inventory, hunger, resource gathering, base building."
---

# Genre: Survival

Resource scarcity, needs management, and progression through crafting define survival games.

## Available Scripts

### [inventory_slot_resource.gd](scripts/inventory_slot_resource.gd)
Expert inventory slot pattern using Resources for save compatibility.

## Core Loop
1.  **Harvest**: Gather resources (Wood, Stone, Food)
2.  **Craft**: Convert resources into tools/items
3.  **Build**: Construct shelter/base
4.  **Survive**: Manage needs (Hunger, Thirst, Environmental threats)
5.  **Thrive**: Automation and tech to transcend early struggles

## NEVER Do in Survival Games

- **NEVER make gathering tedious without scaling** — 50 clicks for 1 wood = fun-killer. Tool tiers MUST multiply yield: Stone Axe = 3 wood, Steel = 10 wood. Respect player time.
- **NEVER use instant death for starvation** — 0% hunger → instant death = cheap. Use gradual HP drain (2 HP/sec). Player should see death coming and scramble for food.
- **NEVER allow infinite inventory stacking** — 999 stacks of everything removes resource management strategy. Use weight systems OR stack limits (64 per slot).
- **NEVER make crafting recipes a guessing game** — Trial-and-error crafting = 1990s design. Show discovered recipes. Discovery can exist, but once learned, must be persistent.
- **NEVER let needs decay at constant rate regardless of activity** — Hunger drains same speed while sleeping/running? Unrealistic. Sprint = 3x drain, idle = 0.5x drain.
- **NEVER spawn enemies near player's bed/spawn point** — Dying, respawning into 3 enemies = rage quit. Enforce safe zone radius (50m) around respawn.

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
- Master Skill: [godot-master](../godot-master/SKILL.md)
