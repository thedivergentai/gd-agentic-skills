class_name LootTable extends Resource

## Data-driven weighted loot table using Godot 4 native optimization.
## Avoids slow GDScript loops for probability calculation.

@export var items: Array[Resource] = []
@export var weights: PackedFloat32Array = PackedFloat32Array()

## Uses native rand_weighted for O(1) or O(log N) speed depending on size.
func roll_item(rng: RandomNumberGenerator) -> Resource:
	if items.is_empty() or weights.size() != items.size():
		push_error("LootTable: Weights size mismatch or empty items.")
		return null
		
	var rolled_idx := rng.rand_weighted(weights)
	return items[rolled_idx]

func add_entry(item: Resource, weight: float) -> void:
	items.append(item)
	weights.append(weight)
