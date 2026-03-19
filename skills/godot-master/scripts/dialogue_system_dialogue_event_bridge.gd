# dialogue_event_bridge.gd
# Triggering game logic from conversation nodes
extends Node

func _ready():
	DialogueManager.line_started.connect(_on_line_started)

func _on_line_started(node: DialogueNode):
	if node.event_signal != "":
		# Assumes a GlobalEventBus or similar
		if get_tree().root.has_node("GlobalBus"):
			get_node("/root/GlobalBus").emit_signal(node.event_signal)
