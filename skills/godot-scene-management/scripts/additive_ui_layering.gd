# additive_ui_layering.gd
# Managing multiple UI layouts without replacing the whole scene
extends Node

# EXPERT NOTE: Don't change the entire scene for just a menu. 
# Load UI scenes as children of a persistent 'UI' node.

func open_menu(path: String):
	var scene = load(path).instantiate()
	add_child(scene)
	# Pause game logic if it's a pause menu
	get_tree().paused = true

func close_menu(menu: Node):
	menu.queue_free()
	get_tree().paused = false
