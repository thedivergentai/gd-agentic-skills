---
name: godot-inventory-system
description: "Expert blueprint for inventory systems (Diablo, Resident Evil, Minecraft) covering slot-based containers, stacking logic, weight limits, equipment systems, and drag-drop UI. Use when building RPG inventories, survival item management, or loot systems. Keywords inventory, slot, stack, equipment, crafting, item, Resource, drag-drop."
---

# Inventory System

Slot management, stacking logic, and resource-based items define robust inventory systems.

## Available Scripts

### [grid_inventory_logic.gd](scripts/grid_inventory_logic.gd)
Expert grid inventory with tetris-style placement logic.

### [inventory_grid.gd](scripts/inventory_grid.gd)
Grid-based inventory controller with drag-and-drop foundations and auto-sorting.

## NEVER Do in Inventory Systems

- **NEVER use Nodes for items** — `Item extends Node` = memory leak nightmare. Inventory with 100 items = 100 nodes in tree. Use `Item extends Resource` for save compatibility.
- **NEVER forget to check max_stack before adding** — `add_item()` without stack logic = items disappear silently. ALWAYS attempt stacking BEFORE creating new slots.
- **NEVER modify inventory directly from UI** — `InventorySlotUI.item = null` on click = desynced state. UI should emit signals, Inventory model updates, THEN UI refreshes via signals.
- **NEVER use float for item quantities** — Floating-point error: 10.0 - 0.1 * 100 ≠ 0. Use `int` for countable items. Only use float for weight/volume limits.
- **NEVER forget to validate weight/capacity before adding** — Player adds 1000kg item to 100kg inventory? Must check `get_total_weight() + item.weight * amount <= max_weight` BEFORE adding.
- **NEVER emit `inventory_changed` inside loop** — Adding 100 items = 100 UI refreshes = lag spike. Batch operations, emit ONCE after loop completes.

---

## Core Architecture

```gdscript
# item.gd (Resource)
class_name Item
extends Resource

@export var id: String
@export var display_name: String
@export var icon: Texture2D
@export var max_stack: int = 1
@export var weight: float = 0.0
@export_multiline var description: String
```

## Inventory Manager

```gdscript
# inventory.gd
class_name Inventory
extends Resource

signal item_added(item: Item, amount: int)
signal item_removed(item: Item, amount: int)
signal inventory_changed

@export var slots: Array[InventorySlot] = []
@export var max_slots: int = 20
@export var max_weight: float = 100.0

func _init() -> void:
    slots.resize(max_slots)
    for i in max_slots:
        slots[i] = InventorySlot.new()

func add_item(item: Item, amount: int = 1) -> bool:
    var remaining := amount
    
    # Try stacking first
    if item.max_stack > 1:
        for slot in slots:
            if slot.item == item and slot.amount < item.max_stack:
                var space := item.max_stack - slot.amount
                var to_add := mini(space, remaining)
                slot.amount += to_add
                remaining -= to_add
                
                if remaining <= 0:
                    item_added.emit(item, amount)
                    inventory_changed.emit()
                    return true
    
    # Add to empty slots
    while remaining > 0:
        var empty_slot := find_empty_slot()
        if empty_slot == null:
            return false  # Inventory full
        
        var to_add := mini(item.max_stack, remaining)
        empty_slot.item = item
        empty_slot.amount = to_add
        remaining -= to_add
    
    item_added.emit(item, amount)
    inventory_changed.emit()
    return true

func remove_item(item: Item, amount: int = 1) -> bool:
    var remaining := amount
    
    for slot in slots:
        if slot.item == item:
            var to_remove := mini(slot.amount, remaining)
            slot.amount -= to_remove
            remaining -= to_remove
            
            if slot.amount <= 0:
                slot.clear()
            
            if remaining <= 0:
                item_removed.emit(item, amount)
                inventory_changed.emit()
                return true
    
    return false  # Not enough items

func has_item(item: Item, amount: int = 1) -> bool:
    var count := 0
    for slot in slots:
        if slot.item == item:
            count += slot.amount
    return count >= amount

func find_empty_slot() -> InventorySlot:
    for slot in slots:
        if slot.is_empty():
            return slot
    return null

func get_total_weight() -> float:
    var total := 0.0
    for slot in slots:
        if slot.item:
            total += slot.item.weight * slot.amount
    return total
```

## Inventory Slot

```gdscript
# inventory_slot.gd
class_name InventorySlot
extends Resource

signal slot_changed

var item: Item = null
var amount: int = 0

func is_empty() -> bool:
    return item == null

func clear() -> void:
    item = null
    amount = 0
    slot_changed.emit()
```

## Equipment System

```gdscript
# equipment.gd
class_name Equipment
extends Resource

signal equipment_changed(slot: String, item: Item)

@export var weapon: Item = null
@export var armor: Item = null
@export var accessory: Item = null

func equip(slot: String, item: Item) -> Item:
    var old_item: Item = null
    
    match slot:
        "weapon":
            old_item = weapon
            weapon = item
        "armor":
            old_item = armor
            armor = item
        "accessory":
            old_item = accessory
            accessory = item
    
    equipment_changed.emit(slot, item)
    return old_item

func unequip(slot: String) -> Item:
    return equip(slot, null)

func get_total_stats() -> Dictionary:
    var stats := {
        "attack": 0,
        "defense": 0,
        "speed": 0
    }
    
    for item in [weapon, armor, accessory]:
        if item and item.has("stats"):
            for key in item.stats:
                stats[key] += item.stats[key]
    
    return stats
```

## UI Integration

```gdscript
# inventory_ui.gd
extends Control

@onready var grid := $GridContainer
var inventory: Inventory

func _ready() -> void:
    inventory.inventory_changed.connect(refresh_ui)
    refresh_ui()

func refresh_ui() -> void:
    # Clear existing
    for child in grid.get_children():
        child.queue_free()
    
    # Create slot UI
    for slot in inventory.slots:
        var slot_ui := InventorySlotUI.new()
        slot_ui.setup(slot)
        grid.add_child(slot_ui)
```

## Crafting Integration

```gdscript
# crafting_recipe.gd
class_name CraftingRecipe
extends Resource

@export var result: Item
@export var result_amount: int = 1
@export var requirements: Array[CraftingRequirement]

func can_craft(inventory: Inventory) -> bool:
    for req in requirements:
        if not inventory.has_item(req.item, req.amount):
            return false
    return true

func craft(inventory: Inventory) -> bool:
    if not can_craft(inventory):
        return false
    
    # Remove ingredients
    for req in requirements:
        inventory.remove_item(req.item, req.amount)
    
    # Add result
    inventory.add_item(result, result_amount)
    return true
```

## Save/Load

```gdscript
func save_inventory() -> Dictionary:
    return {
        "slots": slots.map(func(s): return s.to_dict())
    }

func load_inventory(data: Dictionary) -> void:
    for i in data.slots.size():
        slots[i].from_dict(data.slots[i])
    inventory_changed.emit()
```

## Best Practices

1. **Use Resources** - Items as Resources, not class instances
2. **Signal-Driven UI** - Emit signals, let UI listen
3. **Stack Logic** - Always check `max_stack` first
4. **Weight Limits** - Validate before adding

## Reference
- Related: `godot-save-load-systems`, `godot-resource-data-patterns`


### Related
- Master Skill: [godot-master](../godot-master/SKILL.md)
