# custom_data_resource.gd
# Defining serialized data containers
class_name ItemData extends Resource

# EXPERT NOTE: Resources are pure data. Using class_name allows 
# them to be instantiated in the Inspector as .tres files.

@export var name: String = "Unknown Item"
@export var icon: Texture2D
@export var base_value: int = 10
@export_multiline var description: String = ""

# Constructor with default values is REQUIRED for Inspector support
func _init(p_name: String = "Unknown", p_value: int = 10):
	name = p_name
	base_value = p_value
