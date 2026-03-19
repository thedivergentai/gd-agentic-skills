# skills/genre-survival/scripts/inventory_data.gd
class_name InventoryData
extends Resource

## Inventory Data (Expert Pattern)
## Resource-based inventory system compatible with Save/Load.

signal inventory_updated(slot_index: int)

@export var slots: Array[InventorySlotData] = []

func _init(num_slots: int = 20) -> void:
    slots.resize(num_slots)
    for i in range(num_slots):
        slots[i] = InventorySlotData.new()

func add_item(item: Resource, amount: int) -> int:
    var remaining = amount
    
    # 1. Stack with existing
    for i in range(slots.size()):
        if remaining <= 0: break
        var slot = slots[i]
        if slot.item == item and slot.count < slot.max_stack:
            var space = slot.max_stack - slot.count
            var to_add = min(remaining, space)
            slot.count += to_add
            remaining -= to_add
            inventory_updated.emit(i)
            
    # 2. Add to empty
    for i in range(slots.size()):
        if remaining <= 0: break
        var slot = slots[i]
        if slot.item == null:
            slot.item = item
            var to_add = min(remaining, slot.max_stack) # Assuming item has specific max stack info elsewhere
            slot.count = to_add
            remaining -= to_add
            inventory_updated.emit(i)
            
    return remaining

# Inner Class for Slot cannot be exported strictly as resource in same file in 4.x usually
# But for simplicity in this pattern we define usage. 
# Best practice: Separate file for SlotData.
# Here we assume InventorySlotData is a known class or we use Dictionary if simple.
# For this script, we'll assume InventorySlotData is defined below or externally.

## EXPERT USAGE:
## Create as .tres for default loadouts.
## Use add_item returns to handle "Inventory Full".
