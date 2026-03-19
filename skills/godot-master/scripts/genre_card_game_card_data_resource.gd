# card_data_resource.gd
# Defining cards as lightweight data-driven Resources
class_name CardData extends Resource

# EXPERT NOTE: Resources allow designers to edit card stats 
# in the Godot Inspector, saving them as .tres files.

@export var card_name: String = "Blank"
@export var mana_cost: int = 1
@export var attack: int = 0
@export var health: int = 1

# Setter with changed emission for reactive UI
func update_stats(new_atk, new_hp):
	attack = new_atk
	health = new_hp
	emit_changed()
