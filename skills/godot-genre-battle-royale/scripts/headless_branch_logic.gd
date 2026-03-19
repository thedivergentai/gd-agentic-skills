# headless_branch_logic.gd
# Dedicated server pathing for battle royale hosts
extends Node

# EXPERT NOTE: Dedicated servers must skip UI and input 
# and use optimized physics drivers (Dummy).

func _ready():
	if DisplayServer.get_name() == "headless":
		_server_init()
	else:
		_client_init()

func _server_init():
	# Configure server-only timers or state update rates
	multiplayer.peer_connected.connect(_on_peer_connected)
	print("Dedicated Server active for Battle Royale session.")

func _on_peer_connected(id): pass
func _client_init(): pass
