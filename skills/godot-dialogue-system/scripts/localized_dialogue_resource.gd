# localized_dialogue_resource.gd
# Professional localization strategy
extends DialogueResource

# EXPERT NOTE: Store translation keys in nodes instead 
# of raw text to support multiple languages via .csv files.

func get_node_text(node_id: String) -> String:
	var node = nodes[node_id]
	return tr(node.text_key)
