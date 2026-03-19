# enet_optimized_host.gd
# Configuring high-performance UDP hosts for Godot servers
extends Node

# EXPERT NOTE: ENet is the preferred protocol for action games. 
# Defining precise bandwidth and client limits is vital for stability.

func setup_enet_server(port: int, max_clients: int):
	var peer := ENetMultiplayerPeer.new()
	# Port, Max Clients, Channels (0 for default), In/Out Bandwidth (0 for unlimited)
	var err := peer.create_server(port, max_clients, 0, 0, 0)
	
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Server listening on port ", port)
	else:
		push_error("ENet Server Setup Failed: ", err)
