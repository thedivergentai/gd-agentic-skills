# scene_tree_dump.gd
# Debugging orphan nodes and tree bloat
extends Node

# EXPERT NOTE: Use print_tree_pretty() to see a snapshot 
# of the current active hierarchy in the terminal.

func log_tree_state():
	print_rich("[color=yellow]--- SCENE TREE DUMP ---[/color]")
	get_tree().root.print_tree_pretty()
