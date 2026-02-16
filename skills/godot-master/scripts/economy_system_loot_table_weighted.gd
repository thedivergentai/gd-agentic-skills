# godot-master/scripts/economy_system_loot_table_weighted.gd
extends Resource

## Weighted Loot Table Expert Pattern
## Uses cumulative probability for high-precision drop distribution.

class_name LootTable

@export var items: Array[LootItem] = []

func get_random_item() -> Resource:
    var total_weight = 0.0
    for item in items:
        total_weight += item.weight
    
    var roll = randf() * total_weight
    var cumulative_weight = 0.0
    
    for item in items:
        cumulative_weight += item.weight
        if roll <= cumulative_weight:
            return item.item_resource
    
    return null

## Supporting Resource Type
class LootItem extends Resource:
    @export var item_resource: Resource
    @export var weight: float = 1.0 # Higher = more common
    @export var tier: int = 1       # Optional metadata for filtering

## EXPERT NOTE:
## Storing loot tables as Resources allows designers to swap tables 
## (e.g., 'Normal Chest' vs 'Boss Chest') in the inspector without code changes.
