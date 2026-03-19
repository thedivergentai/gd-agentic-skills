# skills/genre-survival/scripts/inventory_slot_data.gd
class_name InventorySlotData
extends Resource

## Inventory Slot Data (Expert Pattern)
## Separate resource for individual slots to allow easy serialization.

@export var item: Resource # Reference to ItemDefinition
@export var count: int = 0
@export var max_stack: int = 64 # Should theoretically come from Item Resource

func can_stack_with(other_slot: InventorySlotData) -> bool:
    return item == other_slot.item and item != null and count < max_stack

## EXPERT USAGE:
## Used internally by InventoryData.
