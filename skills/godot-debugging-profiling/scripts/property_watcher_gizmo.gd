# property_watcher_gizmo.gd
# Monitoring variables without print spam
extends Node

# EXPERT NOTE: Use a label or custom gizmo to track 
# fast-changing variables (velocity, state) visually.

@onready var label = $DebugLabel

func _process(_delta):
	var parent = get_parent()
	if parent:
		label.text = "State: %s\nVel: %s" % [parent.state, parent.velocity]
