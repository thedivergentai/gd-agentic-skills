# dialogue_option_data.gd
# Interactive player choices
class_name DialogueOption extends Resource

@export var text: String = ""
@export var next_node_id: String = ""
@export var condition_script: String = "" # Optional GDScript snippet
