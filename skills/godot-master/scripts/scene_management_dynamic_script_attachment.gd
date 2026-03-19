# dynamic_script_attachment.gd
# Attaching scripts to nodes at runtime [Modding System]
extends Node

func apply_script_to_node(node: Node, script_path: String):
	var script = load(script_path)
	if script is Script:
		node.set_script(script)
		# Re-run _ready if needed, or call init
		node.notification(NOTIFICATION_READY)
