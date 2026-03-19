# nested_subtween_cutscene.gd
# Hierarchical cutscene timing using tween_subtween()
extends Node

# EXPERT NOTE: Combine multiple complex sequences into a main 
# timeline using subtweens for modular cutscene management.

func play_sequence():
	var sub = create_tween()
	sub.tween_property($Actor, "rotation", PI, 1.0)
	sub.tween_property($Actor, "rotation", 0, 1.0)
	
	var main = create_tween()
	main.tween_property($Actor, "position:x", 500, 2.0)
	# Main timeline waits for the rotation sequence to finish
	main.tween_subtween(sub)
	main.tween_property($Actor, "modulate:a", 0, 1.0)
