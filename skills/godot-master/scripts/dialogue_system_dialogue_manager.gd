# godot-master/scripts/dialogue_system_dialogue_manager.gd
extends Node

## Dialogue Manager Expert Pattern
## Data-driven dialogue system with branching and conditional logic.

class_name DialogueManager

signal dialogue_started
signal line_started(character: String, text: String)
signal choices_presented(choices: Array)
signal dialogue_ended

var _current_dialogue_resource: Dictionary
var _current_node_id: String
var _variables: Dictionary = {}

# Example Data Structure:
# {
#   "start": {
#       "text": "Hello traveler.",
#       "character": "Guard",
#       "next": "choice_1"
#   },
#   "choice_1": {
#       "type": "choice",
#       "choices": [
#           {"text": "Hi!", "next": "greeting_friendly"},
#           {"text": "Move aside.", "next": "confrontation"}
#       ]
#   }
# }

func start_dialogue(dialogue_data: Dictionary, start_node := "start") -> void:
	_current_dialogue_resource = dialogue_data
	_current_node_id = start_node
	dialogue_started.emit()
	_process_node(_current_node_id)

func advance_dialogue(choice_index := -1) -> void:
	var node = _current_dialogue_resource.get(_current_node_id)
	if not node:
		end_dialogue()
		return
		
	if node.get("type") == "choice":
		if choice_index < 0:
			push_error("Must provide choice index for choice node")
			return
		var choices = node.get("choices", [])
		if choice_index >= choices.size():
			push_error("Invalid choice index")
			return
		
		var next_id = choices[choice_index].get("next")
		_process_node(next_id)
	else:
		# Standard text node
		if node.has("next"):
			_process_node(node["next"])
		else:
			end_dialogue()

func _process_node(node_id: String) -> void:
	_current_node_id = node_id
	var node = _current_dialogue_resource.get(node_id)
	
	if not node:
		end_dialogue()
		return
	
	# Execute side effects (variable setting)
	if node.has("set_var"):
		var setter = node["set_var"]
		_variables[setter.key] = setter.value
	
	# Check conditions
	if node.has("condition_key"):
		var key = node["condition_key"]
		var req_val = node["condition_value"]
		if _variables.get(key) != req_val:
			# Condition failed, go to else_next
			if node.has("else_next"):
				_process_node(node["else_next"])
			return
	
	var type = node.get("type", "text")
	
	if type == "text":
		line_started.emit(node.get("character", "???"), node.get("text", "..."))
	elif type == "choice":
		choices_presented.emit(node.get("choices", []))

func end_dialogue() -> void:
	dialogue_ended.emit()

## EXPERT USAGE:
## var dlg = DialogueManager.new()
## dlg.line_started.connect(_on_line)
## dlg.start_dialogue(json_data)
