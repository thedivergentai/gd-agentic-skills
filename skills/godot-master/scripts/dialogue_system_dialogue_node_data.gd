# dialogue_node_data.gd
# Single step in a conversation
class_name DialogueNode extends Resource

@export var speaker_name: String = ""
@export var portrait: Texture2D
@export_multiline var text: String = ""
@export var options: Array[DialogueOption] = []
@export var event_signal: String = "" # Optional signal to emit
