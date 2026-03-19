# headless_init_manager.gd
# Detecting and initializing dedicated server environments
extends Node

# EXPERT NOTE: DisplayServer.get_name() returns "headless" 
# only if the binary was launched with the --headless argument.

func _ready():
	if DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server"):
		print_rich("[color=green]DEDICATED SERVER DETECTED[/color]")
		_start_server_logic()

func _start_server_logic():
	# Configure server-specific singletons or physics speeds
	Engine.max_fps = 60 # Servers don't need high FPS, but need stability
