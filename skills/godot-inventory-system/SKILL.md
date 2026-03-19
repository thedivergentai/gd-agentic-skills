---
name: godot-inventory-system
description: "Expert blueprint for inventory systems (Diablo, Resident Evil, Minecraft) covering slot-based containers, stacking logic, weight limits, equipment systems, and drag-drop UI. Use when building RPG inventories, survival item management, or loot systems. Keywords inventory, slot, stack, equipment, crafting, item, Resource, drag-drop."
---

# Inventory System

Slot management, stacking logic, and resource-based items define robust inventory systems.

## Available Scripts

### [inventory_item_resource.gd](scripts/inventory_item_resource.gd)
Base Resource for all inventory items, allowing for serialized `.tres` item databases.

### [item_slot_data.gd](scripts/item_slot_data.gd)
Reactive data structure for a single inventory slot, broadcasting changes to the UI.

### [inventory_data_resource.gd](scripts/inventory_data_resource.gd)
Centralized Resource for managing inventory arrays, stacking logic, and empty slot finding.

### [inventory_ui_controller.gd](scripts/inventory_ui_controller.gd)
Grid-based UI controller that maps `InventoryData` to visual slots using the "Reactive UI" pattern.

### [drag_and_drop_slot.gd](scripts/drag_and_drop_slot.gd)
Native Godot drag-and-drop implementation for moving and swapping inventory items.

### [item_database_loader.gd](scripts/item_database_loader.gd)
Global registry pattern to efficiently load and lookup items by unique ID strings.

### [inventory_persistence.gd](scripts/inventory_persistence.gd)
Expert logic for serializing and deserializing complex inventory structures to disk.

### [consumable_item_logic.gd](scripts/consumable_item_logic.gd)
Extension pattern for implementing specific item behaviors (Potions, Food) via inheritance.

### [loot_table_resource.gd](scripts/loot_table_resource.gd)
Data-driven loot distribution definition for random drops and chest contents.

### [item_pickup_node.gd](scripts/item_pickup_node.gd)
World-space bridge for converting physical 2D/3D pickups into inventory data.

## NEVER Do in Inventory Systems

- **NEVER use Nodes for items** — `Item extends Node` leads to massive SceneTree bloat and memory leaks. Always use `Item extends Resource` for lightweight data [20].
- **NEVER attempt to add items without checking stack limits** — Adding to an inventory without pre-scanning for existing stacks causes item duplication or loss [21].
- **NEVER allow the UI to modify the Inventory Data directly** — If UI code clears a slot without notifying the data model, you'll get desyncs and ghost items [22].
- **NEVER use `float` for item quantities** — Floating point errors (e.g. 0.9999 instead of 1) will break your "equal to zero" checks. Stick to `int` for counts [23].
- **NEVER add items before validating weight or volume capacity** — Moving validation check *after* adding the item makes it impossible to prevent over-encumbrance [24].
- **NEVER emit signals for every single item inside a batch operation** — Adding 50 items = 50 UI updates. Emit a single `inventory_updated` signal after the loop completes [25].
- **NEVER hardcode item references in scripts** — Use a String ID and a central `ItemDatabase` to look up resources. This is CRITICAL for save system compatibility.
- **NEVER ignore `is_instance_valid()` when accessing item icons** — If a slot's item is null, trying to access `.icon` will crash the UI.
- **NEVER use complex Array logic in the UI** — The UI should only "reflect" the data. All sorting, stacking, and filtering logic belongs in the `InventoryData` resource.
- **NEVER create new `Resource` instances inside a `_process()` loop** — Pre-instantiate your inventory slots or reuse existing ones to prevent allocation spikes.

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
