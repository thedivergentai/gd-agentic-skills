# cross_autoload_comms.gd
# Rules for Autoload-to-Autoload communication
extends Node

# EXPERT NOTE: Avoid circular dependencies between Autoloads.
# If A needs B and B needs A, your project will likely hang on boot.

func _ready():
	# Use 'await' if checking for a sibling Autoload's node tree
	if not get_tree().root.has_node("SaveManager"):
		await get_tree().process_frame # Give other singletons time to init
		
	_initialize_hooks()

func _initialize_hooks():
	# Connecting to another Singleton safely
	if get_tree().root.has_node("SaveManager"):
		var sm = get_node("/root/SaveManager")
		sm.save_requested.connect(_on_save)

func _on_save():
	pass
