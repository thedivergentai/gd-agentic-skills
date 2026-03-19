# dialogue_manager_singleton.gd
# Managing conversation state and signals
extends Node

# EXPERT NOTE: The DialogueManager handles the traversal 
# of the DialogueResource tree.

signal line_started(node: DialogueNode)
signal dialogue_finished

var current_dialogue: DialogueResource
var current_node: DialogueNode

func start_dialogue(res: DialogueResource):
	current_dialogue = res
	_show_node(res.start_node)

func select_option(index: int):
	var option = current_node.options[index]
	_show_node(option.next_node_id)

func _show_node(node_id: String):
	if node_id == "end" or not current_dialogue.nodes.has(node_id):
		dialogue_finished.emit()
		return
		
	current_node = current_dialogue.nodes[node_id]
	line_started.emit(current_node)
