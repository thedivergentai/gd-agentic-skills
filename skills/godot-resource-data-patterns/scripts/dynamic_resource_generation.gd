# dynamic_resource_generation.gd
# Creating and modifying Resources at runtime
extends Node

func create_procedural_loot():
	var loot = ItemData.new("Magic Sword", 500)
	loot.description = "Generated at: " + Time.get_datetime_string_from_system()
	
	# We can now pass this around as a lightweight data object
	_give_to_player(loot)

func _give_to_player(_item: ItemData):
	pass
