# LootTableResource.gd
# Randomized item drops definition
class_name LootTable extends Resource

# EXPERT NOTE: Defining loot tables as Resources allow you 
# to assign "EliteTable" to bosses and "TrashTable" to minions.

@export var possible_items: Array[InventoryItem] = []
@export var drop_chances: Array[float] = []

func get_random_drop() -> InventoryItem:
	var roll = randf()
	# Weighted random calculation here...
	return possible_items[0] # Placeholder
