---
name: godot-resource-data-patterns
description: "Expert blueprint for data-oriented design using Resource/RefCounted classes (item databases, character stats, reusable data structures). Covers typed arrays, serialization, nested resources, and resource caching. Use when implementing data systems OR inventory/stats/dialogue databases. Keywords Resource, RefCounted, ItemData, CharacterStats, database, serialization, @export, typed arrays."
---

# Resource & Data Patterns

Resource-based design, typed arrays, and serialization define reusable, inspector-friendly data structures.

## Available Scripts

### [data_factory_resource.gd](scripts/data_factory_resource.gd)
Expert resource factory with type validation and batch instantiation.

### [resource_pool.gd](scripts/resource_pool.gd)
Object pooling for Resource instances - reduces allocation overhead in hot paths.

### [resource_validator.gd](scripts/resource_validator.gd)
Validates Resource files for missing exports and configuration issues.

> **MANDATORY - For Data Systems**: Read data_factory_resource.gd before implementing item/stat databases.


## NEVER Do in Resource Design

- **NEVER modify resource instances without duplicating** — `player.stats.health -= 10` on loaded resource? Modifies the `.tres` file on disk. MUST use `.duplicate()` first.
- **NEVER use untyped arrays** — `@export var items: Array = []` accepts ANY type = runtime errors. Use `Array[ItemData]` for type safety + autocomplete.
- **NEVER forget @export for inspector editing** — Resource property without `@export`? Invisible in Inspector. Use `@export` for editable properties.
- **NEVER put logic in base Resource** — `Resource` has no lifecycle (`_ready`, `_process`). Use `extends RefCounted` for runtime logic OR attach to Node.
- **NEVER serialize Node references** — `@export var player_node: Node` in Resource? Breaks on save/load. Store NodePath OR UID instead.
- **NEVER use ResourceSaver.save() without error check** — `ResourceSaver.save(res, path)` can fail (permissions, invalid path). MUST check return error code.

---

| Type | Use Case | Serializable | Can Save to Disk | Inspector Support |
|------|----------|-------------|-----------------|-------------------|
| `Resource` | Data that needs saving/loading | ✅ | ✅ | ✅ |
| `RefCounted` | Temporary runtime data | ❌ | ❌ | ❌ |
| `Node` | Scene hierarchy entities | ✅ (scene files) | ✅ | ✅ |

## When to Use Resources

**Use Resources For:**
- Item definitions (weapons, consumables, equipment)
- Character stats/progression systems
- Skill/ability data
- Configuration files
- Dialogue databases
- Enemy/NPC templates

**Use RefCounted For:**
- Temporary calculations
- Runtime-only state machines
- Utility classes without data persistence

## Implementation Patterns

### Pattern 1: Custom Resource Class

```gdscript
# item_data.gd
extends Resource
class_name ItemData

@export var item_name: String = ""
@export var description: String = ""
@export_enum("Weapon", "Consumable", "Armor") var item_type: int = 0
@export var icon: Texture2D
@export var value: int = 0
@export var stackable: bool = false
@export var max_stack: int = 1

func use() -> void:
    match item_type:
        0:  # Weapon
            print("Equipped weapon: ", item_name)
        1:  # Consumable
            print("Consumed: ", item_name)
        2:  # Armor
            print("Equipped armor: ", item_name)
```

**Create Resource Instances:**
1. In Inspector: **Right-click → New Resource → ItemData**
2. Fill in properties, **Save** as `res://items/health_potion.tres`

### Pattern 2: Character Stats Resource

```gdscript
# character_stats.gd
extends Resource
class_name CharacterStats

@export var max_health: int = 100
@export var max_mana: int = 50
@export var strength: int = 10
@export var defense: int = 5
@export var speed: float = 100.0

var current_health: int = max_health:
    set(value):
        current_health = clampi(value, 0, max_health)

var current_mana: int = max_mana:
    set(value):
        current_mana = clampi(value, 0, max_mana)

func take_damage(amount: int) -> int:
    var actual_damage := maxi(amount - defense, 0)
    current_health -= actual_damage
    return actual_damage

func heal(amount: int) -> void:
    current_health += amount

func duplicate_stats() -> CharacterStats:
    var stats := CharacterStats.new()
    stats.max_health = max_health
    stats.max_mana = max_mana
    stats.strength = strength
    stats.defense = defense
    stats.speed = speed
    stats.current_health = current_health
    stats.current_mana = current_mana
    return stats
```

**Usage:**
```gdscript
# player.gd
extends CharacterBody2D

@export var stats: CharacterStats

func _ready() -> void:
    if stats:
        # Create runtime copy to avoid modifying the original resource
        stats = stats.duplicate_stats()
```

### Pattern 3: Database Pattern (Array of Resources)

```gdscript
# item_database.gd
extends Resource
class_name ItemDatabase

@export var items: Array[ItemData] = []

func get_item_by_name(item_name: String) -> ItemData:
    for item in items:
        if item.item_name == item_name:
            return item
    return null

func get_items_by_type(item_type: int) -> Array[ItemData]:
    var filtered: Array[ItemData] = []
    for item in items:
        if item.item_type == item_type:
            filtered.append(item)
    return filtered
```

**Create Database:**
1. Create `ItemDatabase` resource
2. Expand `items` array in Inspector
3. Add `ItemData` resources to array
4. Save as `res://data/item_database.tres`

**Usage:**
```gdscript
# Global autoload
const ITEM_DB := preload("res://data/item_database.tres")

func get_item(name: String) -> ItemData:
    return ITEM_DB.get_item_by_name(name)
```

### Pattern 4: Runtime-Only Data (RefCounted)

For data that doesn't need persistence:

```gdscript
# damage_calculation.gd
extends RefCounted
class_name DamageCalculation

var base_damage: int
var critical_hit: bool
var damage_type: String

func calculate_final_damage(target_defense: int) -> int:
    var final_damage := base_damage - target_defense
    if critical_hit:
        final_damage *= 2
    return maxi(final_damage, 1)
```

**Usage:**
```gdscript
var calc := DamageCalculation.new()
calc.base_damage = 50
calc.critical_hit = randf() > 0.8
calc.damage_type = "physical"
var damage := calc.calculate_final_damage(enemy.defense)
```

## Advanced Patterns

### Pattern 5: Nested Resources

```gdscript
# weapon_data.gd
extends ItemData
class_name WeaponData

@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var special_effects: Array[StatusEffect] = []

# status_effect.gd
extends Resource
class_name StatusEffect

@export var effect_name: String
@export var duration: float
@export var damage_per_second: int
```

### Pattern 6: Resource Scripts with Signals

```gdscript
# inventory.gd
extends Resource
class_name Inventory

signal item_added(item: ItemData)
signal item_removed(item: ItemData)

var items: Array[ItemData] = []

func add_item(item: ItemData) -> void:
    items.append(item)
    item_added.emit(item)

func remove_item(item: ItemData) -> void:
    items.erase(item)
    item_removed.emit(item)
```

### Pattern 7: Resource Loading at Runtime

```gdscript
# Load resource dynamically
var item: ItemData = load("res://items/sword.tres")

# Preload for better performance (compile-time)
const SWORD := preload("res://items/sword.tres")

# Load all resources in a directory
func load_all_items() -> Array[ItemData]:
    var items: Array[ItemData] = []
    var dir := DirAccess.open("res://items/")
    if dir:
        dir.list_dir_begin()
        var file_name := dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var item: ItemData = load("res://items/" + file_name)
                items.append(item)
            file_name = dir.get_next()
    return items
```

## Best Practices

### 1. Always Duplicate Resources in Runtime

```gdscript
# ✅ Good - create instance copy
@export var stats: CharacterStats
func _ready():
    stats = stats.duplicate()  # Or custom duplicate method

# ❌ Bad - modifies the original resource file
@export var stats: CharacterStats
func _ready():
    stats.current_health -= 10  # This changes the .tres file!
```

### 2. Use `@export` for Inspector Editing

```gdscript
# ✅ Makes properties editable in Inspector
@export var max_health: int = 100
@export var icon: Texture2D
@export_range(0, 100) var drop_chance: int = 50
```

### 3. Organize Resources by Category

```
res://data/
    items/
        weapons/
            sword.tres
            bow.tres
        consumables/
            health_potion.tres
    characters/
        player_stats.tres
        enemy_goblin.tres
    databases/
        item_database.tres
```

### 4. Type Your Arrays

```gdscript
# ✅ Good - typed array
@export var items: Array[ItemData] = []

# ❌ Bad - untyped array
@export var items: Array = []
```

## Saving/Loading Resources

```gdscript
# Save resource to disk
func save_inventory(inventory: Inventory, path: String) -> void:
    ResourceSaver.save(inventory, path)

# Load resource from disk
func load_inventory(path: String) -> Inventory:
    if ResourceLoader.exists(path):
        return ResourceLoader.load(path)
    return null
```

## Reference
- [Godot Docs: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Docs: Data Preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html)


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
