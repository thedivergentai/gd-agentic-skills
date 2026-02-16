> [!NOTE]
> **Resource Context**: This module provides expert patterns for **Resource & Data Patterns**. Accessed via Godot Master.

# Resource & Data Patterns

Resource-based design, typed arrays, and serialization define reusable, inspector-friendly data structures.

## Available Scripts

### [data_factory_resource.gd](../scripts/resource_data_patterns_data_factory_resource.gd)
Expert resource factory with type validation and batch instantiation.

### [resource_pool.gd](../scripts/resource_data_patterns_resource_pool.gd)
Object pooling for Resource instances - reduces allocation overhead in hot paths.

### [resource_validator.gd](../scripts/resource_data_patterns_resource_validator.gd)
Validates Resource files for missing exports and configuration issues.

> **MANDATORY - For Data Systems**: Read [data_factory_resource.gd](../scripts/resource_data_patterns_data_factory_resource.gd) before implementing item/stat databases.


## NEVER Do in Resource Design

- **NEVER modify resource instances without duplicating** — `player.stats.health -= 10` on loaded resource? Modifies the `.tres` file on disk. MUST use `.duplicate()` first.
- **NEVER use untyped arrays** — `@export var items: Array = []` accepts ANY type = runtime errors. Use `Array[ItemData]` for type safety + autocomplete.
- **NEVER forget @export for inspector editing** — Resource property without `@export`? Invisible in Inspector. Use `@export` for editable properties.
- **NEVER put logic in base Resource** — `Resource` has no lifecycle (`_ready`, `_process`). Use `extends RefCounted` for runtime logic OR attach to Node.
- **NEVER serialize Node references** — `@export var player_node: Node` in Resource? Breaks on save/load. Store NodePath OR UID instead.
- **NEVER use ResourceSaver.save() without error check** — `ResourceSaver.save(res, path)` can fail. MUST check return error code.

---

## When to Use Resources

**Use Resources For:**
- Item definitions (weapons, consumables)
- Character stats/progression systems
- Skill/ability data
- Configuration files
- Dialogue databases

**Use RefCounted For:**
- Temporary calculations
- Runtime-only state machines
- Utility classes without data persistence

## Implementation Patterns

### Pattern: Custom Resource Class
```gdscript
# item_data.gd
extends Resource
class_name ItemData

@export var item_name: String = ""
@export var description: String = ""
@export_enum("Weapon", "Consumable", "Armor") var item_type: int = 0
```

### Pattern: Character Stats (with runtime duplication)
```gdscript
# player.gd
extends CharacterBody2D

@export var stats: CharacterStats

func _ready() -> void:
    if stats:
        # Create runtime copy to avoid modifying the original resource file
        stats = stats.duplicate()
```

## Best Practices
1. **Always Duplicate Resources at Runtime**: Use `duplicate()` to ensure you don't overwrite source files during gameplay.
2. **Use `@export`**: Make properties visible in the Inspector for artists and designers.
3. **Type Your Arrays**: Use typed arrays like `Array[ItemData]` for better IDE support and safety.

## Reference
- [Godot Docs: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Docs: Data Preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html)
