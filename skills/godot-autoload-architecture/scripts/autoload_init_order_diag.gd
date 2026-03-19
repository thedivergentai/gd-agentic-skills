# autoload_init_order_diag.gd
# Checking Autoload initialization sequence
extends Node

# EXPERT NOTE: Autoloads initialize in the order they appear in 
# Project Settings -> AutoLoad. Use this for dependency debugging.

func _ready():
	print("[AutoLoad Diagnostic] Initialized: ", name)
	
	# Check for dependencies. If 'GlobalConfig' must be first:
	if not get_tree().root.has_node("GlobalConfig"):
		push_error("CRITICAL: GlobalConfig Autoload missing or loaded after %s!" % name)
