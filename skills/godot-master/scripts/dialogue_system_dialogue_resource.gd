# dialogue_resource.gd
# Data-driven conversation tree
class_name DialogueResource extends Resource

# EXPERT NOTE: Dialogue should be stored in Resources to 
# allow for branching paths and localization keys.

@export var start_node: String = "start"
@export var nodes: Dictionary = {} # node_id -> DialogueNode
