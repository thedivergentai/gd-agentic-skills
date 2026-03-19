# nested_resource_serialization.gd
# Building complex data hierarchies with Resources
class_name QuestData extends Resource

# EXPERT NOTE: Resources can contain other Resources. 
# Godot handles the nested serialization automatically.

@export var title: String
@export var rewards: Array[ItemData]
@export var start_stats_requirement: CharacterStats
