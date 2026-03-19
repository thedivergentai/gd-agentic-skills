# server_dedicated_host.gd
# Configuring a dedicated server instance
extends Node

# EXPERT NOTE: For dedicated servers, use ENetMultiplayerPeer 
# and disable the scene tree rendering if not needed (Server build).

func start_dedicated_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		printerr("Server startup failed: ", error)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_client_connected)
	print("Dedicated server listening on ", port)

func _on_client_connected(id: int):
	print("Client connected: ", id)
