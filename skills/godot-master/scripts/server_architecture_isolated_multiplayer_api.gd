# isolated_multiplayer_api.gd
# Running Client and Server instances in a single Godot run
extends Node

# EXPERT NOTE: Use for Local Hosting where the same instance 
# needs to act as both authoritative server and local client.

func split_branches():
	var server_api = MultiplayerAPI.create_default_interface()
	# Isolate the /root/Server branch to its own MultiplayerAPI root
	get_tree().set_multiplayer(server_api, ^"/root/Server")
	
	print("Network branches isolated: Client and Server now run independently.")
