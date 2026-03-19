# engine_editor_hint_logic.gd
# Debug tools that run inside the Editor
@tool
extends Node3D

# EXPERT NOTE: Use Engine.is_editor_hint() to run 
# visualization tools safely while designing.

func _process(_delta):
	if Engine.is_editor_hint():
		# Update gizmo or helper mesh in real-time
		pass
