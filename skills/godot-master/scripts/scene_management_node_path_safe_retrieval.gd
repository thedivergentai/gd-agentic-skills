# node_path_safe_retrieval.gd
# Robust node path handling to prevent 'Null Instance' errors
extends Node

# EXPERT NOTE: Avoid hardcoded Nodepaths like get_node("../../Player") 
# as they break if the hierarchy changes. Use @onready and Unique Names.

@onready var player = %Player # Using Scene Unique Name (%)

func _ready() -> void:
	if not player:
		push_error("Critical error: Player not found in scene!")
