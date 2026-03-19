# network_error_handler.gd
# Gracefully handling disconnects and timeouts
extends Node

func _ready():
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_server_disconnected():
	# Transition back to main menu with cleanup
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_connection_failed():
	printerr("Failed to establish network link.")
