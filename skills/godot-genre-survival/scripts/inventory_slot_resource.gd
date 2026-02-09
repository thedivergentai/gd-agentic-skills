# skills/genre-survival/code/inventory_slot_resource.gd
extends Resource
class_name InventorySlot

## Survival Inventory Expert Pattern
## Uses Resources for type-safety and modularity.

@export var item_id: String = ""
@export var quantity: int = 0
@export var max_stack: int = 99
@export var item_icon: Texture2D
@export var metadata: Dictionary = {} # Store durability, mods, etc.

func can_add(amount: int) -> bool:
    return (quantity + amount) <= max_stack

func add(amount: int) -> void:
    quantity += amount

func use() -> bool:
    if quantity > 0:
        quantity -= 1
        return true
    return false

## EXPERT NOTE:
## NEVER use a simple 'Dictionary' [id, count] for survival inventories. 
## Using a 'Resource' allows each item to store unique state (Durability, 
## Custom Names, Enchantments) and enables easy use of the Inspector 
## for balancing.
## For 'genre-survival', implement a 'Weighted Inventory' system where the 
## total weight of all Slot resources affects the player's move speed.
