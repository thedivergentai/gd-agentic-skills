---
name: godot-game-loop-collection
description: Use when implementing collection quests, scavenger hunts, or "find all X" objectives.
---

# Collection Game Loops

## Overview
This skill provides a standardized framework for "Collection Loops" – gameplay objectives where the player must find and gather a specific set of items (e.g., hidden eggs, data logs, coins).

## Core Components

### 1. Collection Manager (`collection_manager.gd`)
The central brain of the hunt.
- **Role**: Tracks progress (`current / target`).
- **Behavior**: Listens for `item_collected(id)` -> Updates items -> Signals `collection_completed` on valid count.
- **Tip**: Use `collection_id` strings to run multiple hunts simultaneously (e.g., "red_eggs" vs "blue_eggs").

### 2. Collectible Item (`collectible_item.gd`)
The physical object in the world.
- **Role**: Handles interaction and self-destruction.
- **Behavior**: On Interact -> Play VFX -> Emit Signal -> Queue Free.

### 3. Hidden Item Spawner (`hidden_item_spawner.gd`)
Automates the placement of items.
- **Role**: Populates the level.
- **Behavior**: Instantiates the item scene at:
    -   Hand-placed `Marker3D` nodes (Deterministic).
    -   Random points within a `CollisionShape` volume (Procedural).

## Usage Example

```gdscript
# In a Level Script or Game Mode
@onready var manager = $CollectionManager

func _ready():
    manager.start_collection("easter_egg_2024", 10)
    manager.collection_completed.connect(_on_all_eggs_found)

func _on_all_eggs_found():
    print("You found all the eggs! Here is a bunny hat.")
    # Unlock reward
```

## Best Practices
- **Persistence**: Combine with `godot-mechanic-secrets` to save which specific IDs have been found if the player needs to quit and resume.
- **NEVER hardcode spawn positions in code**: Always use `Marker3D` or `CollisionShape3D` nodes in the scene so designers can adjust layout without touching code.
- **Avoid "God Objects"**: The `CollectionManager` shouldn't handle input, UI, AND audio. Let it emit signals and let other systems react.
- **Juice**: Always spawn particles or play a sound *before* the item disappears. Immediate `queue_free()` feels dry.
