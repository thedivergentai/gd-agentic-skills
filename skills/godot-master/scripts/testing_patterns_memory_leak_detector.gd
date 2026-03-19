# memory_leak_detector.gd
# Capturing object count regressions
extends Node

# EXPERT NOTE: A sudden spike in Performance.OBJECT_COUNT 
# usually indicates nodes or resources that aren't being 
# freed correctly (orphans).

func _process(_delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		var orphans = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
		if orphans > 0:
			print_rich("[color=red]ORPHAN NODES DETECTED: [/color]", orphans)
