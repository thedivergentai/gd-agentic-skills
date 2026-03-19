# client_network_setup.gd
# Connecting to a remote server
extends Node

# EXPERT NOTE: Ensure the protocol (ENet/WebSocket) matches 
# the server. ENet is preferred for UDP-based fast action.

func connect_to_server(address: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		printerr("Connection failed: ", error)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connection_success)

func _on_connection_success():
	print("Successfully connected to host!")
